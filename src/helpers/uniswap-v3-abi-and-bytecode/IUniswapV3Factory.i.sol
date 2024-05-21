// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma experimental ABIEncoderV2;

interface IUniswapV3Factory {
    struct Parameters {
        address factory;
        address token0;
        address token1;
        uint24 fee;
        int24 tickSpacing;
    }

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event PoolCreated(
        address indexed token0, address indexed token1, uint24 indexed fee, int24 tickSpacing, address pool
    );

    function createPool(address tokenA, address tokenB, uint24 fee) external returns (address pool);
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
    function feeAmountTickSpacing(uint24) external view returns (int24);
    function getPool(address, address, uint24) external view returns (address);
    function owner() external view returns (address);
    function parameters() external view returns (Parameters memory);
    function setOwner(address _owner) external;
}
