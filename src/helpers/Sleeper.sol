// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import { Test } from "forge-std/Test.sol";

contract SleepViaVMWarp is Test {
    function setUp() public { }

    function sleep(uint256 t) public {
        uint256 blockTimePreWarp = block.timestamp;
        vm.warp(block.timestamp + t);
        uint256 blockTimePostWarp = block.timestamp;
        require(blockTimePostWarp >= blockTimePreWarp + t);
    }
}
