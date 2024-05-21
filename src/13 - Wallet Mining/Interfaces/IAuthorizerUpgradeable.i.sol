// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect AuthorizerUpgradeable abi)"
interface IAuthorizerUpgradeable {
    event AdminChanged(address previousAdmin, address newAdmin);
    event BeaconUpgraded(address indexed beacon);
    event Initialized(uint8 version);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Rely(address indexed usr, address aim);
    event Upgraded(address indexed implementation);

    function can(address usr, address aim) external view returns (bool);
    function init(address[] memory _wards, address[] memory _aims) external;
    function owner() external view returns (address);
    function proxiableUUID() external view returns (bytes32);
    function renounceOwnership() external;
    function transferOwnership(address newOwner) external;
    function upgradeTo(address newImplementation) external;
    function upgradeToAndCall(address imp, bytes memory wat) external payable;
}
