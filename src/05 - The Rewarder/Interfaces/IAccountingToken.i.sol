// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect AccountingToken abi)"
interface IAccountingToken {
    error NewOwnerIsZeroAddress();
    error NoHandoverRequest();
    error NotImplemented();
    error Unauthorized();

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipHandoverCanceled(address indexed pendingOwner);
    event OwnershipHandoverRequested(address indexed pendingOwner);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event RolesUpdated(address indexed user, uint256 indexed roles);
    event Snapshot(uint256 id);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function BURNER_ROLE() external view returns (uint256);
    function MINTER_ROLE() external view returns (uint256);
    function SNAPSHOT_ROLE() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);
    function burn(address from, uint256 amount) external;
    function cancelOwnershipHandover() external payable;
    function completeOwnershipHandover(address pendingOwner) external payable;
    function decimals() external view returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function grantRoles(address user, uint256 roles) external payable;
    function hasAllRoles(address user, uint256 roles) external view returns (bool result);
    function hasAnyRole(address user, uint256 roles) external view returns (bool result);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function mint(address to, uint256 amount) external;
    function name() external view returns (string memory);
    function ordinalsFromRoles(uint256 roles) external pure returns (uint8[] memory ordinals);
    function owner() external view returns (address result);
    function ownershipHandoverExpiresAt(address pendingOwner) external view returns (uint256 result);
    function ownershipHandoverValidFor() external view returns (uint64);
    function renounceOwnership() external payable;
    function renounceRoles(uint256 roles) external payable;
    function requestOwnershipHandover() external payable;
    function revokeRoles(address user, uint256 roles) external payable;
    function rolesFromOrdinals(uint8[] memory ordinals) external pure returns (uint256 roles);
    function rolesOf(address user) external view returns (uint256 roles);
    function snapshot() external returns (uint256);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function totalSupplyAt(uint256 snapshotId) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transferOwnership(address newOwner) external payable;
}
