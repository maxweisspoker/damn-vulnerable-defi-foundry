// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}
