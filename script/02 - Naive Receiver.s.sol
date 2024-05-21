// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { IFlashLoanReceiver } from "../src/02 - Naive Receiver/Interfaces/IFlashLoanReceiver.i.sol";
import { INaiveReceiverLenderPool } from "../src/02 - Naive Receiver/Interfaces/INaiveReceiverLenderPool.i.sol";

//////////////////////////////////////////////////////////////////////////////////////////
import { IAmASharkSwimmingInThePool } from "../src/02 - Naive Receiver/YOUR_SOLUTION.sol";
//////////////////////////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed set of Naive receiver contracts
contract NaiveReceiverScript is Script {
    INaiveReceiverLenderPool private pool;
    IFlashLoanReceiver private receiver;

    address private constant POOL_ADDRESS = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant RECEIVER_ADDRESS = 0x0000000000000000000000000000000000000000; // change me!!!

    function setUp() public {
        pool = INaiveReceiverLenderPool(payable(POOL_ADDRESS));
        receiver = IFlashLoanReceiver(payable(RECEIVER_ADDRESS));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
