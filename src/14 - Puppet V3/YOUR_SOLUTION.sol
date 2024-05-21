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

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. Feel free to alter them or to remove them if you don't use
    // them.
    receive() external payable { }
    fallback() external payable { }
}
