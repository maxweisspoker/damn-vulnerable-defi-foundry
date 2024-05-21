// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect PuppetPool abi)"
interface IPuppetPool {
    error NotEnoughCollateral();
    error TransferFailed();

    event Borrowed(address indexed account, address recipient, uint256 depositRequired, uint256 borrowAmount);

    // solhint-disable-next-line func-name-mixedcase
    function DEPOSIT_FACTOR() external view returns (uint256);
    function borrow(uint256 amount, address recipient) external payable;
    function calculateDepositRequired(uint256 amount) external view returns (uint256);
    function deposits(address) external view returns (uint256);
    function token() external view returns (address);
    function uniswapPair() external view returns (address);
}
