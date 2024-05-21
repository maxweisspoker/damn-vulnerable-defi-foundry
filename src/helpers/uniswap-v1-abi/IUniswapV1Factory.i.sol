// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IUniswapV1Factory {
    event NewExchange(address indexed token, address indexed exchange);

    function createExchange(address token) external returns (address out);
    function exchangeTemplate() external returns (address out);
    function getExchange(address token) external returns (address out);
    function getToken(address exchange) external returns (address out);
    function getTokenWithId(uint256 token_id) external returns (address out);
    function initializeFactory(address template) external;
    function tokenCount() external returns (uint256 out);
}
