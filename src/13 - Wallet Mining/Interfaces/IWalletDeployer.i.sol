// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect WalletDeployer abi)"
interface IWalletDeployer {
    error Boom();

    function can(address u, address a) external view returns (bool);
    function chief() external view returns (address);
    function copy() external view returns (address);
    function drop(bytes memory wat) external returns (address aim);
    function fact() external view returns (address);
    function gem() external view returns (address);
    function mom() external view returns (address);
    function pay() external view returns (uint256);
    function rule(address _mom) external;
}
