// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect FlashLoanerPool abi)"
interface IFlashLoanerPool {
    error CallerIsNotContract();
    error FlashLoanNotPaidBack();
    error NotEnoughTokenBalance();

    function flashLoan(uint256 amount) external;
    function liquidityToken() external view returns (address);
}
