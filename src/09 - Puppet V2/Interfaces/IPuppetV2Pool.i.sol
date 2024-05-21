// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

// Created by running "cast interface <(forge inspect PuppetV2Pool abi)"
interface IPuppetV2Pool {
    event Borrowed(address indexed borrower, uint256 depositRequired, uint256 borrowAmount, uint256 timestamp);

    function borrow(uint256 borrowAmount) external;
    function calculateDepositOfWETHRequired(uint256 tokenAmount) external view returns (uint256 ret);
    function deposits(address) external view returns (uint256);
}
