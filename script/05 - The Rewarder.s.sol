// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IAccountingToken } from "../src/05 - The Rewarder/Interfaces/IAccountingToken.i.sol";
import { IFlashLoanerPool } from "../src/05 - The Rewarder/Interfaces/IFlashLoanerPool.i.sol";
import { IRewardToken } from "../src/05 - The Rewarder/Interfaces/IRewardToken.i.sol";
import { ITheRewarderPool } from "../src/05 - The Rewarder/Interfaces/ITheRewarderPool.i.sol";
import { AccountingToken } from "../src/05 - The Rewarder/AccountingToken.sol";
import { FlashLoanerPool } from "../src/05 - The Rewarder/FlashLoanerPool.sol";
import { RewardToken } from "../src/05 - The Rewarder/RewardToken.sol";
import { TheRewarderPool } from "../src/05 - The Rewarder/TheRewarderPool.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";

////////////////////////////////////////////////////////////////////////
import { IAmAWinner } from "../src/05 - The Rewarder/YOUR_SOLUTION.sol";
////////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed set of "The Rewarder" contracts
contract TheRewarderScript is Script {
    IERC20 private liquidityToken;
    IAccountingToken private accountingToken;
    IRewardToken private rewardToken;
    IFlashLoanerPool private flashLoanPool;
    ITheRewarderPool private rewarderPool;

    address private constant liquidityToken_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant accountingToken_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant rewardToken_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant flashLoanPool_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant rewarderPool_address = 0x0000000000000000000000000000000000000000; // change me!!!

    function setUp() public {
        liquidityToken = IERC20(payable(liquidityToken_address));
        accountingToken = IAccountingToken(payable(accountingToken_address));
        rewardToken = IRewardToken(payable(rewardToken_address));
        flashLoanPool = IFlashLoanerPool(payable(flashLoanPool_address));
        rewarderPool = ITheRewarderPool(payable(rewarderPool_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
