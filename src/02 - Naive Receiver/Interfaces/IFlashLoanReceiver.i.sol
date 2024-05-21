// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect FlashLoanReceiver abi)"
interface IFlashLoanReceiver {
    error UnsupportedCurrency();

    receive() external payable;

    function onFlashLoan(address, address token, uint256 amount, uint256 fee, bytes memory)
        external
        returns (bytes32);
}
