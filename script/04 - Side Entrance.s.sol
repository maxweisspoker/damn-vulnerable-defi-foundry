// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { ISideEntranceLenderPool } from "../src/04 - Side Entrance/Interfaces/ISideEntranceLenderPool.i.sol";

/////////////////////////////////////////////////////////////////////////////
import { IAmASidewinder } from "../src/04 - Side Entrance/YOUR_SOLUTION.sol";
/////////////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed set of Naive receiver contracts
contract SideEntranceScript is Script {
    ISideEntranceLenderPool private pool;

    address private constant POOL_ADDRESS = 0x0000000000000000000000000000000000000000; // change me!!!

    function setUp() public {
        pool = ISideEntranceLenderPool(payable(POOL_ADDRESS));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
