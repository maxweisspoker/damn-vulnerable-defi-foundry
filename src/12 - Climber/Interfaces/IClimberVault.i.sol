// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect ClimberVault abi)"
interface IClimberVault {
    error CallerNotSweeper();
    error InvalidWithdrawalAmount();
    error InvalidWithdrawalTime();

    event AdminChanged(address previousAdmin, address newAdmin);
    event BeaconUpgraded(address indexed beacon);
    event Initialized(uint8 version);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Upgraded(address indexed implementation);

    function getLastWithdrawalTimestamp() external view returns (uint256);
    function getSweeper() external view returns (address);
    function initialize(address admin, address proposer, address sweeper) external;
    function owner() external view returns (address);
    function proxiableUUID() external view returns (bytes32);
    function renounceOwnership() external;
    function sweepFunds(address token) external;
    function transferOwnership(address newOwner) external;
    function upgradeTo(address newImplementation) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
    function withdraw(address token, address recipient, uint256 amount) external;
}
