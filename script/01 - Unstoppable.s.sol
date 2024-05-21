// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";
import { IUnstoppableVault } from "../src/01 - Unstoppable/Interfaces/IUnstoppableVault.i.sol";
import { IReceiverUnstoppable } from "../src/01 - Unstoppable/Interfaces/IReceiverUnstoppable.i.sol";

///////////////////////////////////////////////////////////////////////////
import { IAmUnstoppable } from "../src/01 - Unstoppable/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed set of Unstoppable contracts
contract UnstoppableScript is Script {
    IUnstoppableVault private vault;
    IReceiverUnstoppable private receiverContract;

    address payable private constant VAULT_ADDRESS = payable(0x0000000000000000000000000000000000000000); // change me!!!
    address payable private constant RECEIVER_ADDRESS = payable(0x0000000000000000000000000000000000000000); // change me!!!

    function setUp() public {
        vault = IUnstoppableVault(VAULT_ADDRESS);
        receiverContract = IReceiverUnstoppable(RECEIVER_ADDRESS);
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
