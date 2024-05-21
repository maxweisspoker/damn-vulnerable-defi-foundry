// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { TrusterLenderPool } from "../src/03 - Truster/TrusterLenderPool.sol";
import { ITrusterLenderPool } from "../src/03 - Truster/Interfaces/ITrusterLenderPool.i.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";

///////////////////////////////////////////////////////////////////////////
import { FasterThanTheFlash } from "../src/03 - Truster/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////////////

contract TrusterTest is Test {
    DamnValuableToken private token;
    TrusterLenderPool private pool;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Truster deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Truster player")))));

    uint256 private constant TOKENS_IN_POOL = 1000000 * 1e18;

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/truster/truster.challenge.js
    function setUp() public {
        vm.startPrank(deployer);
        token = new DamnValuableToken();
        pool = new TrusterLenderPool(token);
        require(address(pool.token()) == address(token));

        token.transfer(address(pool), TOKENS_IN_POOL);
        require(token.balanceOf(address(pool)) == TOKENS_IN_POOL);

        require(token.balanceOf(address(player)) == 0);
        vm.stopPrank();
    }

    function test_Truster() public {
        vm.startPrank(player, player);

        FasterThanTheFlash theflash = new FasterThanTheFlash(address(pool), address(player));
        theflash.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        // Player has taken all tokens from the pool
        require(
            token.balanceOf(player) == TOKENS_IN_POOL,
            "Sorry, you did not solve the challenge! Player should have all tokens from the pool"
        );
        require(
            token.balanceOf(address(pool)) == 0,
            "Sorry, you did not solve the challenge! Pool should not have any tokens"
        );

        console.log("Congratulations, you solved the challenge! You are faster than the Flash!!!");
    }

    function test_truster() public {
        return test_Truster();
    }

    function test_03() public {
        return test_Truster();
    }
}
