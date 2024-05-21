// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;

// Created by running "cast interface <(forge inspect PuppetV3Pool abi)"
interface IPuppetV3Pool {
    event Borrowed(address indexed borrower, uint256 depositAmount, uint256 borrowAmount);

    function DEPOSIT_FACTOR() external view returns (uint256);
    function TWAP_PERIOD() external view returns (uint32);
    function borrow(uint256 borrowAmount) external;
    function calculateDepositOfWETHRequired(uint256 amount) external view returns (uint256);
    function deposits(address) external view returns (uint256);
    function token() external view returns (address);
    function uniswapV3Pool() external view returns (address);
    function weth() external view returns (address);
}
