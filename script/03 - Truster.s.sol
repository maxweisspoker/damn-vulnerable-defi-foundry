// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { ITrusterLenderPool } from "../src/03 - Truster/Interfaces/ITrusterLenderPool.i.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

///////////////////////////////////////////////////////////////////////////
import { FasterThanTheFlash } from "../src/03 - Truster/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed TrusterLenderPool contract
contract TrusterScript is Script {
    IERC20 private token;
    ITrusterLenderPool private pool;

    uint256 private constant TOKENS_IN_POOL = 1000000 * 1e18;

    address private constant TRUSTER_POOL_ADDRESS = 0x0000000000000000000000000000000000000000; // change me!!!

    function setUp() public {
        pool = ITrusterLenderPool(payable(TRUSTER_POOL_ADDRESS));
        token = IERC20(address(pool.token()));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
