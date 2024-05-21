// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect TrustfulOracleInitializer abi)"
interface ITrustfulOracleInitializer {
    event NewTrustfulOracle(address oracleAddress);

    function oracle() external view returns (address);
}
