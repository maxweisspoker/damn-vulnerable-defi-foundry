// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import { Script, console } from "forge-std/Script.sol";
import { IERC20 } from "../src/09 - Puppet V2/Interfaces/IERC20.i.sol";
import { IWETH } from "../src/09 - Puppet V2/Interfaces/IWETH.i.sol";
import { PuppetV2Pool } from "../src/09 - Puppet V2/PuppetV2Pool.sol";
import { IPuppetV2Pool } from "../src/09 - Puppet V2/Interfaces/IPuppetV2Pool.i.sol";
import { IUniswapV2Factory } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Factory.i.sol";
import { IUniswapV2Router02 } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Router02.i.sol";
import { IUniswapV2Pair } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Pair.i.sol";
import { UniswapV2Library } from "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

/////////////////////////////////////////////////////////////////////////
import { PuppetMasterV2 } from "../src/09 - Puppet V2/YOUR_SOLUTION.sol";
/////////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed set of "Puppet" contracts
contract PuppetV2Script is Script {
    IERC20 private token;
    IPuppetV2Pool private lendingPool;
    IWETH private weth;
    IUniswapV2Factory private uniswapFactory;
    IUniswapV2Router02 private uniswapRouter;

    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant lendingPool_address = 0x0000000000000000000000000000000000000000; // change me!!!

    // addresses on Ethereum mainnet
    address private constant weth_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant uniswapFactory_address = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant uniswapRouter_address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        token = IERC20(payable(token_address));
        lendingPool = IPuppetV2Pool(payable(lendingPool_address));
        weth = IWETH(payable(weth_address));
        uniswapFactory = IUniswapV2Factory(payable(uniswapFactory_address));
        uniswapRouter = IUniswapV2Router02(payable(uniswapRouter_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
