// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect AuthorizedExecutor abi)"
interface IAuthorizedExecutor {
    error AlreadyInitialized();
    error NotAllowed();

    event Initialized(address who, bytes32[] ids);

    function execute(address target, bytes memory actionData) external returns (bytes memory);
    function getActionId(bytes4 selector, address executor, address target) external pure returns (bytes32);
    function initialized() external view returns (bool);
    function permissions(bytes32) external view returns (bool);
    function setPermissions(bytes32[] memory ids) external;
}
