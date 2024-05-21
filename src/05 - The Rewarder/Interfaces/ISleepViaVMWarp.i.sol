// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;

interface ISleepViaVMWarp {
    // Increases the block timestamp by the input number of seconds
    function sleep(uint256) external;
}
