// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import { Script, console } from "forge-std/Script.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { IUniswapV3Factory } from "../src/helpers/uniswap-v3-abi-and-bytecode/IUniswapV3Factory.i.sol";
import { INonfungiblePositionManager } from
    "../src/helpers/uniswap-v3-abi-and-bytecode/INonfungiblePositionManager.i.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { IWETH } from "../src/09 - Puppet V2/Interfaces/IWETH.i.sol";
import { IERC20 } from "../src/09 - Puppet V2/Interfaces/IERC20.i.sol";
import { PuppetV3Pool } from "../src/14 - Puppet V3/PuppetV3Pool.sol";

/////////////////////////////////////////////////////////////////////////
import { PuppetMasterV3 } from "../src/14 - Puppet V3/YOUR_SOLUTION.sol";
/////////////////////////////////////////////////////////////////////////

contract PuppetV3Script is Script {
    IUniswapV3Factory private uniswapFactory;
    INonfungiblePositionManager private uniswapPositionManager;
    IWETH private weth;
    IERC20 private token;
    IUniswapV3Pool private uniswapPool;
    ISwapRouter private uniswapRouter;
    PuppetV3Pool private lendingPool;

    uint24 private constant FEE = 3000;

    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant lendingPool_address = 0x0000000000000000000000000000000000000000; // change me!!!

    // Ethereum mainnet addresses
    address private constant uniswapFactory_address = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address private constant uniswapPositionManager_address = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address private constant weth_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant uniswapRouter_address = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    function setUp() public {
        weth = IWETH(payable(weth_address));
        uniswapFactory = IUniswapV3Factory(payable(uniswapFactory_address));
        uniswapRouter = ISwapRouter(payable(uniswapRouter_address));
        uniswapPositionManager = INonfungiblePositionManager(payable(uniswapPositionManager_address));
        token = IERC20(payable(token_address));
        uniswapPool = IUniswapV3Pool(payable(uniswapFactory.getPool(address(token), address(weth), FEE)));
        require(address(uniswapPool) != address(0));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
