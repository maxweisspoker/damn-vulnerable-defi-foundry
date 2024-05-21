// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect WalletRegistry abi)"
interface IWalletRegistry {
    error CallerNotFactory();
    error FakeMasterCopy();
    error InvalidFallbackManager(address fallbackManager);
    error InvalidInitialization();
    error InvalidOwnersCount(uint256 count);
    error InvalidThreshold(uint256 threshold);
    error NewOwnerIsZeroAddress();
    error NoHandoverRequest();
    error NotEnoughFunds();
    error OwnerIsNotABeneficiary();
    error Unauthorized();

    event OwnershipHandoverCanceled(address indexed pendingOwner);
    event OwnershipHandoverRequested(address indexed pendingOwner);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    function addBeneficiary(address beneficiary) external;
    function beneficiaries(address) external view returns (bool);
    function cancelOwnershipHandover() external payable;
    function completeOwnershipHandover(address pendingOwner) external payable;
    function masterCopy() external view returns (address);
    function owner() external view returns (address result);
    function ownershipHandoverExpiresAt(address pendingOwner) external view returns (uint256 result);
    function ownershipHandoverValidFor() external view returns (uint64);
    function proxyCreated(address proxy, address singleton, bytes memory initializer, uint256) external;
    function renounceOwnership() external payable;
    function requestOwnershipHandover() external payable;
    function token() external view returns (address);
    function transferOwnership(address newOwner) external payable;
    function walletFactory() external view returns (address);
    function wallets(address) external view returns (address);
}
