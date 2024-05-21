// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;
pragma experimental ABIEncoderV2;

import { Test, console } from "forge-std/Test.sol";
import { SelfiePool } from "../src/06 - Selfie/SelfiePool.sol";
import { SimpleGovernance } from "../src/06 - Selfie/SimpleGovernance.sol";
import { DamnValuableTokenSnapshot } from "../src/DamnValuableTokenSnapshot.sol";
import { SleepViaVMWarp } from "../src/helpers/Sleeper.sol";

//////////////////////////////////////////////////////////////////////////////
import { OverthrowTheGovernment } from "../src/06 - Selfie/YOUR_SOLUTION.sol";
//////////////////////////////////////////////////////////////////////////////

contract SelfieTest is Test {
    DamnValuableTokenSnapshot private token;
    SimpleGovernance private governance;
    SelfiePool private pool;
    SleepViaVMWarp private sleeper;

    uint256 private constant TOKEN_INITIAL_SUPPLY = 2000000 * 1e18;
    uint256 private constant TOKENS_IN_POOL = 1500000 * 1e18;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Selfie deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Selfie player")))));

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/selfie/selfie.challenge.js
    function setUp() public {
        sleeper = new SleepViaVMWarp();

        vm.startPrank(deployer);

        // Deploy Damn Valuable Token Snapshot
        token = new DamnValuableTokenSnapshot(TOKEN_INITIAL_SUPPLY);

        // Deploy governance contract
        governance = new SimpleGovernance(address(token));

        // Deploy the pool
        pool = new SelfiePool(address(token), address(governance));

        require(address(pool.token()) == address(token));
        require(address(pool.governance()) == address(governance));

        // Fund the pool
        token.transfer(address(pool), TOKENS_IN_POOL);
        token.snapshot();

        require(token.balanceOf(address(pool)) == TOKENS_IN_POOL);
        require(pool.maxFlashLoan(address(token)) == TOKENS_IN_POOL);
        require(pool.flashFee(address(token), 0) == 0);

        vm.stopPrank();
    }

    function test_Selfie() public {
        vm.startPrank(player, player);

        OverthrowTheGovernment revolutionary =
            new OverthrowTheGovernment(address(governance), address(pool), address(token), address(sleeper), player);
        revolutionary.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        require(
            token.balanceOf(player) == TOKENS_IN_POOL,
            "Sorry, you did not solve the challenge! The player must take all of the pool's tokens"
        );
        require(
            token.balanceOf(address(pool)) == 0,
            "Sorry, you did not solve the challenge! The pool must be completely drained of all tokens"
        );

        console.log("Congratulations, you solved the challenge! You are a revolutionary!!!");
    }

    function test_selfie() public {
        return test_Selfie();
    }

    function test_06() public {
        return test_Selfie();
    }
}
