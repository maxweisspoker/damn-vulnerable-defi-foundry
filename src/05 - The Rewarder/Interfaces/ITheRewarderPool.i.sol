// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect TheRewarderPool abi)"
interface ITheRewarderPool {
    error InvalidDepositAmount();

    function REWARDS() external view returns (uint256);
    function accountingToken() external view returns (address);
    function deposit(uint256 amount) external;
    function distributeRewards() external returns (uint256 rewards);
    function isNewRewardsRound() external view returns (bool);
    function lastRecordedSnapshotTimestamp() external view returns (uint64);
    function lastRewardTimestamps(address) external view returns (uint64);
    function lastSnapshotIdForRewards() external view returns (uint128);
    function liquidityToken() external view returns (address);
    function rewardToken() external view returns (address);
    function roundNumber() external view returns (uint64);
    function withdraw(uint256 amount) external;
}
