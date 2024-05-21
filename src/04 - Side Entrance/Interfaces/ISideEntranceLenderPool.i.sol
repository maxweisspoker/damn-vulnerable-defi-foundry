// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect SideEntranceLenderPool abi)"
interface ISideEntranceLenderPool {
    error RepayFailed();

    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    function deposit() external payable;
    function flashLoan(uint256 amount) external;
    function withdraw() external;
}
