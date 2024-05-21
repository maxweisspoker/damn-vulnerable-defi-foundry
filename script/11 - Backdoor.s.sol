// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { IWalletRegistry } from "../src/11 - Backdoor/Interfaces/IWalletRegistry.i.sol";
import { GnosisSafe } from "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import { GnosisSafeProxyFactory } from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

///////////////////////////////////////////////////////////////////
import { Destroyer } from "../src/11 - Backdoor/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////

contract BackdoorScript is Script {
    IWalletRegistry private walletRegistry;
    GnosisSafe private masterCopy;
    GnosisSafeProxyFactory private walletFactory;
    IERC20 private token;

    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant walletRegistry_address = 0x0000000000000000000000000000000000000000; // change me!!!

    // Version 1.1.1 on Ethereum mainnet
    address private constant masterCopy_address = 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F;
    address private constant walletFactory_address = 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B;

    address[] private users = [
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000 // change me!!!
    ];

    function setUp() public {
        walletRegistry = IWalletRegistry(payable(walletRegistry_address));
        masterCopy = GnosisSafe(payable(masterCopy_address));
        walletFactory = GnosisSafeProxyFactory(payable(walletFactory_address));
        token = IERC20(payable(token_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
