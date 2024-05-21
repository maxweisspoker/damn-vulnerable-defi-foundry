// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// Created by running "cast interface <(forge inspect ReceiverUnstoppable abi)"
interface IReceiverUnstoppable {
    error UnexpectedFlashLoan();

    event OwnerUpdated(address indexed user, address indexed newOwner);

    function executeFlashLoan(uint256 amount) external;
    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes memory)
        external
        returns (bytes32);
    function owner() external view returns (address);
    function setOwner(address newOwner) external;
}
