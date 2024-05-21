// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { SelfAuthorizedVault } from "../src/15 - ABI Smuggling/SelfAuthorizedVault.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

///////////////////////////////////////////////////////////////////////
import { Smuggler } from "../src/15 - ABI Smuggling/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////////

contract ABISmugglingTest is Test {
    Smuggler private smuggler;
    SelfAuthorizedVault private vault;
    IERC20 private token;
    bytes32 private deployerPermission;
    bytes32 private playerPermission;
    bytes32 private solverPermission;
    bytes32[] private ids;

    uint256 private constant VAULT_TOKEN_BALANCE = 1000000 * 1e18;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("ABI Smuggling deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("ABI Smuggling player")))));

    address private constant recovery = address(uint160(bytes20(keccak256(abi.encode("ABI Smuggling recovery")))));

    function setUp() public {
        vm.startPrank(deployer);

        // Deploy Damn Valuable Token contract
        token = IERC20(address(new DamnValuableToken()));

        // Deploy Vault
        vault = new SelfAuthorizedVault();
        require(vault.getLastWithdrawalTimestamp() != 0);

        // Set permissions
        deployerPermission = vault.getActionId(0x85fb709d, deployer, address(vault));
        playerPermission = vault.getActionId(0xd9caed12, player, address(vault));
        ids.push(deployerPermission);
        ids.push(playerPermission);

        // Also add solution contract permission
        smuggler = new Smuggler(address(vault), address(token), recovery, player);
        solverPermission = vault.getActionId(0xd9caed12, address(smuggler), address(vault));
        ids.push(solverPermission);

        vault.setPermissions(ids);
        require(vault.permissions(deployerPermission));
        require(vault.permissions(playerPermission));
        require(vault.permissions(solverPermission));

        // Make sure Vault is initialized
        require(vault.initialized());

        // Deposit tokens into the vault
        token.transfer(address(vault), VAULT_TOKEN_BALANCE);

        require(token.balanceOf(address(vault)) == VAULT_TOKEN_BALANCE);
        require(token.balanceOf(player) == 0);

        // Cannot call Vault directly
        vm.expectRevert(abi.encodeWithSignature("CallerNotAllowed()"));
        vault.sweepFunds(deployer, token);

        vm.stopPrank();
        vm.startPrank(player);

        vm.expectRevert(abi.encodeWithSignature("CallerNotAllowed()"));
        vault.withdraw(address(token), player, 1e18);

        vm.stopPrank();
        vm.startPrank(address(smuggler));

        vm.expectRevert(abi.encodeWithSignature("CallerNotAllowed()"));
        vault.withdraw(address(token), player, 1e18);

        vm.expectRevert(abi.encodeWithSignature("CallerNotAllowed()"));
        vault.withdraw(address(token), address(smuggler), 1e18);

        vm.stopPrank();
    }

    function test_ABI_Smuggling() public {
        vm.startPrank(player, player);
        smuggler.solveChallenge();
        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        require(
            token.balanceOf(address(vault)) == 0,
            "Sorry, you did not solve the challenge! Vault must not have any tokens"
        );
        require(token.balanceOf(player) == 0, "Sorry, you did not solve the challenge! Player must not have any tokens");
        require(
            token.balanceOf(recovery) == VAULT_TOKEN_BALANCE,
            "Sorry, you did not solve the challenge! Recovery address must have all the tokens"
        );

        console.log("Congratulations, you solved the challenge! You are an expert smuggler!!!");
    }

    function test_ABISmuggling() public {
        return test_ABI_Smuggling();
    }

    function test_ABI_smuggling() public {
        return test_ABI_Smuggling();
    }

    function test_ABIsmuggling() public {
        return test_ABI_Smuggling();
    }

    function test_abi_Smuggling() public {
        return test_ABI_Smuggling();
    }

    function test_abiSmuggling() public {
        return test_ABI_Smuggling();
    }

    function test_abismuggling() public {
        return test_ABI_Smuggling();
    }

    function test_abi_smuggling() public {
        return test_ABI_Smuggling();
    }

    function test_15() public {
        return test_ABI_Smuggling();
    }
}
