// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";
import { UnstoppableVault } from "../src/01 - Unstoppable/UnstoppableVault.sol";
import { IUnstoppableVault } from "../src/01 - Unstoppable/Interfaces/IUnstoppableVault.i.sol";
import { ReceiverUnstoppable } from "../src/01 - Unstoppable/ReceiverUnstoppable.sol";
import { IReceiverUnstoppable } from "../src/01 - Unstoppable/Interfaces/IReceiverUnstoppable.i.sol";

///////////////////////////////////////////////////////////////////////////
import { IAmUnstoppable } from "../src/01 - Unstoppable/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////////////

contract UnstoppableTest is Test {
    DamnValuableToken private token;
    UnstoppableVault private vault;
    ReceiverUnstoppable private receiverContract;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Unstoppable deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Unstoppable player")))));
    address private constant someUser = address(uint160(bytes20(keccak256(abi.encode("Unstoppable someUser")))));

    uint256 private constant TOKENS_IN_VAULT = 1000000 * 1e18;
    uint256 private constant INITIAL_PLAYER_TOKEN_BALANCE = 10 * 1e18;

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/unstoppable/unstoppable.challenge.js
    function setUp() public {
        vm.startPrank(deployer);

        token = new DamnValuableToken();

        // deployer is both owner and fee recipient
        vault = new UnstoppableVault(token, deployer, deployer);

        require(address(vault.asset()) == address(token));

        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, deployer);

        require(token.balanceOf(address(vault)) == TOKENS_IN_VAULT);
        require(vault.totalAssets() == TOKENS_IN_VAULT);
        require(vault.totalSupply() == TOKENS_IN_VAULT);
        require(vault.maxFlashLoan(address(token)) == TOKENS_IN_VAULT);
        require(vault.flashFee(address(token), TOKENS_IN_VAULT - 1) == 0);
        require(vault.flashFee(address(token), TOKENS_IN_VAULT) == 50000 * 1e18);

        token.transfer(player, INITIAL_PLAYER_TOKEN_BALANCE);
        require(token.balanceOf(player) == INITIAL_PLAYER_TOKEN_BALANCE);

        vm.stopPrank();

        // Show it's possible for someUser to take out a flash loan
        vm.startPrank(someUser);
        receiverContract = new ReceiverUnstoppable(address(vault));
        receiverContract.executeFlashLoan(100 * 1e18);
        vm.stopPrank();
    }

    function test_Unstoppable() public {
        vm.startPrank(player, player);

        IAmUnstoppable unstoppable = new IAmUnstoppable(address(vault), address(receiverContract), player);

        // Give player's tokens to the attack contract
        token.transfer(address(unstoppable), INITIAL_PLAYER_TOKEN_BALANCE);
        require(token.balanceOf(address(unstoppable)) == INITIAL_PLAYER_TOKEN_BALANCE);

        unstoppable.solveChallenge();

        vm.stopPrank();

        // This code tests that your solution works. Do not edit.

        vm.startPrank(someUser);

        // It is no longer possible to execute flash loans
        try receiverContract.executeFlashLoan(100 * 1e18) {
            require(false, "Sorry, you did not solve the challenge! Flash loans can still be executed");
        } catch { }

        console.log("Congratulations, you solved the challenge! You are unstoppable!!!");

        vm.stopPrank();
    }

    function test_unstoppable() public {
        return test_Unstoppable();
    }

    function test_01() public {
        return test_Unstoppable();
    }
}
