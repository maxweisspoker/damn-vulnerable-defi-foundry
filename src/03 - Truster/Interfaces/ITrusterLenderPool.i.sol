// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect TrusterLenderPool abi)"
interface ITrusterLenderPool {
    error RepayFailed();

    function flashLoan(uint256 amount, address borrower, address target, bytes memory data) external returns (bool);
    function token() external view returns (address);
}
