// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { ClimberVault } from "../src/12 - Climber/ClimberVault.sol";
import { IClimberVault } from "../src/12 - Climber/Interfaces/IClimberVault.i.sol";
import { IClimberTimelock } from "../src/12 - Climber/Interfaces/IClimberTimelock.i.sol";
import "../src/12 - Climber/ClimberConstants.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

////////////////////////////////////////////////////////////////////////////////
import { BetterThanTenzingNorgay } from "../src/12 - Climber/YOUR_SOLUTION.sol";
////////////////////////////////////////////////////////////////////////////////

contract ClimberTest is Test {
    IClimberVault private vault;
    IClimberTimelock private timelock;
    DamnValuableToken private token;

    uint256 private constant VAULT_TOKEN_BALANCE = 10000000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 1e17;
    uint64 private constant TIMELOCK_DELAY = 60 * 60;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Climber deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Climber player")))));

    address private constant sweeper = address(uint160(bytes20(keccak256(abi.encode("Climber sweeper")))));
    address private constant proposer = address(uint160(bytes20(keccak256(abi.encode("Climber proposer")))));

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/climber/climber.challenge.js
    function setUp() public {
        vm.startPrank(deployer);

        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        require(player.balance == PLAYER_INITIAL_ETH_BALANCE);

        // Deploy the vault behind a proxy using the UUPS pattern,
        // passing the necessary addresses for the `ClimberVault::initialize(address,address,address)` function
        vault = IClimberVault(
            address(
                new ERC1967Proxy(
                    address(new ClimberVault()),
                    abi.encodeWithSignature("initialize(address,address,address)", deployer, proposer, sweeper)
                )
            )
        );
        require(vault.getSweeper() == sweeper);
        require(vault.getLastWithdrawalTimestamp() > 0);
        require(vault.owner() != address(0));
        require(vault.owner() != deployer);

        // Instantiate timelock
        timelock = IClimberTimelock(payable(address(vault.owner())));

        // Ensure timelock delay is correct and cannot be changed
        require(timelock.delay() == TIMELOCK_DELAY);

        vm.expectRevert(abi.encodeWithSignature("CallerNotTimelock()"));
        timelock.updateDelay(TIMELOCK_DELAY + 1);

        // Ensure timelock roles are correctly initialized
        require(timelock.hasRole(PROPOSER_ROLE, proposer));
        require(timelock.hasRole(ADMIN_ROLE, deployer));
        require(timelock.hasRole(ADMIN_ROLE, address(timelock)));

        // Deploy token and transfer initial token balance to the vault
        token = new DamnValuableToken();
        token.transfer(address(vault), VAULT_TOKEN_BALANCE);

        vm.stopPrank();
    }

    function test_Climber() public {
        vm.startPrank(player, player);

        BetterThanTenzingNorgay climber = new BetterThanTenzingNorgay{ value: player.balance }(
            sweeper, proposer, address(vault), address(token), player
        );
        climber.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.
        require(
            token.balanceOf(address(vault)) == 0,
            "Sorry, you did not solve the challenge! The CLimberVault should not have any DVT tokens"
        );
        require(
            token.balanceOf(player) == VAULT_TOKEN_BALANCE,
            "Sorry, you did not solve the challenge! The player should have all of the vault's DVT tokens"
        );

        console.log("Congratulations, you solved the challenge! You can climb the highest mountain!!!");
    }

    function test_climber() public {
        return test_Climber();
    }

    function test_12() public {
        return test_Climber();
    }
}
