// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect SelfAuthorizedVault abi)"
interface ISelfAuthorizedVault {
    error AlreadyInitialized();
    error CallerNotAllowed();
    error InvalidWithdrawalAmount();
    error NotAllowed();
    error TargetNotAllowed();
    error WithdrawalWaitingPeriodNotEnded();

    event Initialized(address who, bytes32[] ids);

    function WAITING_PERIOD() external view returns (uint256);
    function WITHDRAWAL_LIMIT() external view returns (uint256);
    function execute(address target, bytes memory actionData) external returns (bytes memory);
    function getActionId(bytes4 selector, address executor, address target) external pure returns (bytes32);
    function getLastWithdrawalTimestamp() external view returns (uint256);
    function initialized() external view returns (bool);
    function permissions(bytes32) external view returns (bool);
    function setPermissions(bytes32[] memory ids) external;
    function sweepFunds(address receiver, address token) external;
    function withdraw(address token, address recipient, uint256 amount) external;
}
