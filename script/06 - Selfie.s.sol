// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { ISimpleGovernance } from "../src/06 - Selfie/Interfaces/ISimpleGovernance.i.sol";
import { ISelfiePool } from "../src/06 - Selfie/Interfaces/ISelfiePool.i.sol";
import { DamnValuableTokenSnapshot } from "../src/DamnValuableTokenSnapshot.sol";

//////////////////////////////////////////////////////////////////////////////
import { OverthrowTheGovernment } from "../src/06 - Selfie/YOUR_SOLUTION.sol";
//////////////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed set of "Selfie" contracts
contract SelfieScript is Script {
    DamnValuableTokenSnapshot private token;
    ISelfiePool private pool;
    ISimpleGovernance private governance;

    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant pool_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant governance_address = 0x0000000000000000000000000000000000000000; // change me!!!

    function setUp() public {
        token = DamnValuableTokenSnapshot(payable(token_address));
        pool = ISelfiePool(payable(pool_address));
        governance = ISimpleGovernance(payable(governance_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
