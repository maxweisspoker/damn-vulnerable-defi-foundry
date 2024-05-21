// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { IPuppetPool } from "../src/08 - Puppet/Interfaces/IPuppetPool.i.sol";
import { IUniswapV1Exchange } from "../src/helpers/uniswap-v1-abi/IUniswapV1Exchange.i.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";

////////////////////////////////////////////////////////////////////
import { PuppetMaster } from "../src/08 - Puppet/YOUR_SOLUTION.sol";
////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed set of "Puppet" contracts
contract PuppetScript is Script {
    IPuppetPool private lendingPool;
    IUniswapV1Exchange private exchange;
    DamnValuableToken private token;

    address private constant lendingPool_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant exchange_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!

    function setUp() public {
        lendingPool = IPuppetPool(payable(lendingPool_address));
        exchange = IUniswapV1Exchange(payable(exchange_address));
        token = DamnValuableToken(payable(token_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
