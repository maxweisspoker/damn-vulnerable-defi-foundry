// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect ClimberTimelock abi)"
interface IClimberTimelock {
    type OperationState is uint8;

    error CallerNotTimelock();
    error InvalidDataElementsCount();
    error InvalidTargetsCount();
    error InvalidValuesCount();
    error NewDelayAboveMax();
    error NotReadyForExecution(bytes32 operationId);
    error OperationAlreadyKnown(bytes32 operationId);

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    receive() external payable;

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function delay() external view returns (uint64);
    function execute(address[] memory targets, uint256[] memory values, bytes[] memory dataElements, bytes32 salt)
        external
        payable;
    function getOperationId(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory dataElements,
        bytes32 salt
    ) external pure returns (bytes32);
    function getOperationState(bytes32 id) external view returns (OperationState state);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function operations(bytes32) external view returns (uint64 readyAtTimestamp, bool known, bool executed);
    function renounceRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function schedule(address[] memory targets, uint256[] memory values, bytes[] memory dataElements, bytes32 salt)
        external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function updateDelay(uint64 newDelay) external;
}
