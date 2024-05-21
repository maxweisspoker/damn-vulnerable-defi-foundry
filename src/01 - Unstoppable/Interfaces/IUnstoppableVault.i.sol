// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// Created by running "cast interface <(forge inspect UnstoppableVault abi)"
interface IUnstoppableVault {
    error CallbackFailed();
    error InvalidAmount(uint256 amount);
    error InvalidBalance();
    error UnsupportedCurrency();

    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event FeeRecipientUpdated(address indexed newFeeRecipient);
    event OwnerUpdated(address indexed user, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function FEE_FACTOR() external view returns (uint256);
    function GRACE_PERIOD() external view returns (uint64);
    function allowance(address, address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function asset() external view returns (address);
    function balanceOf(address) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function convertToShares(uint256 assets) external view returns (uint256);
    function decimals() external view returns (uint8);
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function end() external view returns (uint64);
    function feeRecipient() external view returns (address);
    function flashFee(address _token, uint256 _amount) external view returns (uint256 fee);
    function flashLoan(address receiver, address _token, uint256 amount, bytes memory data) external returns (bool);
    function maxDeposit(address) external view returns (uint256);
    function maxFlashLoan(address _token) external view returns (uint256);
    function maxMint(address) external view returns (uint256);
    function maxRedeem(address owner) external view returns (uint256);
    function maxWithdraw(address owner) external view returns (uint256);
    function mint(uint256 shares, address receiver) external returns (uint256 assets);
    function name() external view returns (string memory);
    function nonces(address) external view returns (uint256);
    function owner() external view returns (address);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
    function previewDeposit(uint256 assets) external view returns (uint256);
    function previewMint(uint256 shares) external view returns (uint256);
    function previewRedeem(uint256 shares) external view returns (uint256);
    function previewWithdraw(uint256 assets) external view returns (uint256);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
    function setFeeRecipient(address _feeRecipient) external;
    function setOwner(address newOwner) external;
    function symbol() external view returns (string memory);
    function totalAssets() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
}
