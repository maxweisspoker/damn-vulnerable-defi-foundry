// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect NaiveReceiverLenderPool abi)"
interface INaiveReceiverLenderPool {
    error CallbackFailed();
    error RepayFailed();
    error UnsupportedCurrency();

    receive() external payable;

    function ETH() external view returns (address);
    function flashFee(address token, uint256) external pure returns (uint256);
    function flashLoan(address receiver, address token, uint256 amount, bytes memory data) external returns (bool);
    function maxFlashLoan(address token) external view returns (uint256);
}
