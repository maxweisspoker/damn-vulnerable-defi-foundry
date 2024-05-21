// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;
pragma experimental ABIEncoderV2;

import { Test, console } from "forge-std/Test.sol";
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
import { SleepViaVMWarp } from "../src/helpers/Sleeper.sol";

////////////////////////////////////////////////////////////////////////
import { IAmAWinner } from "../src/05 - The Rewarder/YOUR_SOLUTION.sol";
////////////////////////////////////////////////////////////////////////

contract RewarderTest is Test {
    DamnValuableToken private liquidityToken;
    AccountingToken private accountingToken;
    RewardToken private rewardToken;
    FlashLoanerPool private flashLoanPool;
    TheRewarderPool private rewarderPool;
    SleepViaVMWarp private sleeper;

    uint256 private minterRole;
    uint256 private snapshotRole;
    uint256 private burnerRole;

    address private constant alice = address(uint160(bytes20(keccak256(abi.encode("The Rewarder Alice")))));
    address private constant bob = address(uint160(bytes20(keccak256(abi.encode("The Rewarder Bob")))));
    address private constant charlie = address(uint160(bytes20(keccak256(abi.encode("The Rewarder Charlie")))));
    address private constant david = address(uint160(bytes20(keccak256(abi.encode("The Rewarder David")))));

    address[] private users;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("The Rewarder deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("The Rewarder player")))));

    uint256 private constant TOKENS_IN_LENDER_POOL = 1000000 * 1e18;

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/the-rewarder/the-rewarder.challenge.js
    function setUp() public {
        users.push(alice);
        users.push(bob);
        users.push(charlie);
        users.push(david);

        sleeper = new SleepViaVMWarp();

        vm.startPrank(deployer);

        liquidityToken = new DamnValuableToken();
        flashLoanPool = new FlashLoanerPool(address(liquidityToken));

        // Set initial token balance of the pool offering flash loans
        liquidityToken.transfer(address(flashLoanPool), TOKENS_IN_LENDER_POOL);

        rewarderPool = new TheRewarderPool(address(liquidityToken));
        rewardToken = rewarderPool.rewardToken();
        accountingToken = rewarderPool.accountingToken();

        // Check roles in accounting token
        require(accountingToken.owner() == address(rewarderPool));
        minterRole = accountingToken.MINTER_ROLE();
        snapshotRole = accountingToken.SNAPSHOT_ROLE();
        burnerRole = accountingToken.BURNER_ROLE();
        require(accountingToken.hasAllRoles(address(rewarderPool), minterRole | snapshotRole | burnerRole));

        // Alice, Bob, Charlie and David deposit tokens
        uint256 depositAmount = 100 * 1e18;
        for (uint256 i; i < users.length; ++i) {
            liquidityToken.transfer(users[i], depositAmount);
            vm.stopPrank();
            vm.startPrank(users[i]);
            liquidityToken.approve(address(rewarderPool), depositAmount);
            rewarderPool.deposit(depositAmount);
            vm.stopPrank();
            vm.startPrank(deployer);
            require(accountingToken.balanceOf(users[i]) == depositAmount);
        }
        require(accountingToken.totalSupply() == depositAmount * users.length);
        require(rewardToken.totalSupply() == 0);

        // Advance time 5 days so that depositors can get rewards
        uint256 blockTimePreWarp = block.timestamp;
        vm.warp(block.timestamp + (5 * 24 * 60 * 60));
        uint256 blockTimePostWarp = block.timestamp;
        require(blockTimePostWarp >= blockTimePreWarp + (5 * 24 * 60 * 60));

        // Each depositor gets reward tokens
        uint256 rewardsInRound = rewarderPool.REWARDS();
        for (uint256 i; i < users.length; ++i) {
            vm.stopPrank();
            vm.startPrank(users[i]);
            rewarderPool.distributeRewards();
            vm.stopPrank();
            vm.startPrank(deployer);
            require(rewardToken.balanceOf(users[i]) == rewardsInRound / users.length);
        }
        require(rewardToken.totalSupply() == rewardsInRound);

        // Player starts with zero DVT tokens in balance
        require(liquidityToken.balanceOf(player) == 0);

        // Two rounds must have occurred so far
        require(rewarderPool.roundNumber() == 2);

        vm.stopPrank();
    }

    function test_TheRewarder() public {
        vm.startPrank(player, player);

        IAmAWinner winner = new IAmAWinner(
            address(liquidityToken),
            address(accountingToken),
            address(rewardToken),
            address(flashLoanPool),
            address(rewarderPool),
            address(sleeper),
            player
        );
        winner.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        // Only one round must have taken place
        require(
            rewarderPool.roundNumber() == 3,
            "Sorry, you did not solve the challenge! Only one round must have taken place"
        );

        // Users should get neglegible rewards this round
        for (uint256 i; i < users.length; ++i) {
            vm.startPrank(users[i]);
            rewarderPool.distributeRewards();
            vm.stopPrank();
            uint256 userRewards = rewardToken.balanceOf(users[i]);
            uint256 delta = userRewards - (rewarderPool.REWARDS() / users.length);
            require(
                delta < 1e16, "Sorry, you did not solve the challenge! Users should get neglegible rewards this round"
            );
        }

        // Rewards must have been issued to the player account
        require(
            rewardToken.totalSupply() > rewarderPool.REWARDS(),
            "Sorry, you did not solve the challenge! Rewards must have been issued to the player account"
        );
        require(
            rewardToken.balanceOf(player) > 0,
            "Sorry, you did not solve the challenge! Rewards must have been issued to the player account"
        );

        // The amount of rewards earned should be close to total available amount
        require(
            (rewarderPool.REWARDS() - rewardToken.balanceOf(player)) < 1e17,
            "Sorry, you did not solve the challenge! The amount of rewards earned should be close to the total available amount"
        );

        // Balance of DVT tokens in player and lending pool hasn't changed
        require(
            liquidityToken.balanceOf(player) == 0,
            "Sorry, you did not solve the challenge! Balance of DVT tokens in player account cannot change"
        );
        require(
            liquidityToken.balanceOf(address(flashLoanPool)) == TOKENS_IN_LENDER_POOL,
            "Sorry, you did not solve the challenge! Balance of DVT tokens in lending pool cannot change"
        );

        console.log("Congratulations, you solved the challenge! You are a winner!!!");
    }

    function test_The_Rewarder() public {
        return test_TheRewarder();
    }

    function test_the_rewarder() public {
        return test_TheRewarder();
    }

    function test_therewarder() public {
        return test_TheRewarder();
    }

    function test_Rewarder() public {
        return test_TheRewarder();
    }

    function test_rewarder() public {
        return test_TheRewarder();
    }

    function test_05() public {
        return test_TheRewarder();
    }
}
