// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { SideEntranceLenderPool } from "../src/04 - Side Entrance/SideEntranceLenderPool.sol";
import { IFlashLoanEtherReceiver } from "../src/04 - Side Entrance/Interfaces/IFlashLoanEtherReceiver.i.sol";
import { ISideEntranceLenderPool } from "../src/04 - Side Entrance/Interfaces/ISideEntranceLenderPool.i.sol";

/////////////////////////////////////////////////////////////////////////////
import { IAmASidewinder } from "../src/04 - Side Entrance/YOUR_SOLUTION.sol";
/////////////////////////////////////////////////////////////////////////////

contract SideEntranceTest is Test {
    SideEntranceLenderPool private pool;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Side Entrance deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Side Entrance player")))));

    uint256 private constant ETHER_IN_POOL = 1000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 1 * 1e18;

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/side-entrance/side-entrance.challenge.js
    function setUp() public {
        vm.startPrank(deployer);

        // Deploy pool and fund it
        pool = new SideEntranceLenderPool();
        vm.deal(deployer, ETHER_IN_POOL);
        pool.deposit{ value: ETHER_IN_POOL }();
        require(address(pool).balance == ETHER_IN_POOL);

        vm.stopPrank();

        // Player starts with limited ETH in balance
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        require(player.balance == PLAYER_INITIAL_ETH_BALANCE);
    }

    function test_SideEntrance() public {
        require(
            player.balance == PLAYER_INITIAL_ETH_BALANCE,
            "The test setup did not work correctly, please check it for errors."
        );

        vm.startPrank(player, player);

        IAmASidewinder sidewinder = new IAmASidewinder{ value: player.balance }(address(pool), player);
        sidewinder.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        // Player took all ETH from the pool
        require(address(pool).balance == 0, "Sorry, you did not solve the challenge! Pool should not have any ether");
        require(
            player.balance > ETHER_IN_POOL,
            "Sorry, you did not solve the challenge! Player should have all of the pool's ether"
        );

        console.log("Congratulations, you solved the challenge! You are a sneaky sidewinder!!!");
    }

    function test_Side_Entrance() public {
        return test_SideEntrance();
    }

    function test_sideentrance() public {
        return test_SideEntrance();
    }

    function test_side_entrance() public {
        return test_SideEntrance();
    }

    function test_04() public {
        return test_SideEntrance();
    }
}
