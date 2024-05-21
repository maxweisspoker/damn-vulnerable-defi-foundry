// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { WalletRegistry } from "../src/11 - Backdoor/WalletRegistry.sol";
import { GnosisSafe } from "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import { GnosisSafeProxyFactory } from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";

///////////////////////////////////////////////////////////////////
import { Destroyer } from "../src/11 - Backdoor/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////

contract BackdoorTest is Test {
    address[] private users;
    GnosisSafe private masterCopy;
    GnosisSafeProxyFactory private walletFactory;
    DamnValuableToken private token;
    WalletRegistry private walletRegistry;

    uint256 private constant AMOUNT_TOKENS_DISTRIBUTED = 40 * 1e18;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Backdoor deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Backdoor player")))));

    address private constant alice = address(uint160(bytes20(keccak256(abi.encode("Backdoor alice")))));
    address private constant bob = address(uint160(bytes20(keccak256(abi.encode("Backdoor bob")))));
    address private constant charlie = address(uint160(bytes20(keccak256(abi.encode("Backdoor charlie")))));
    address private constant david = address(uint160(bytes20(keccak256(abi.encode("Backdoor david")))));

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/backdoor/backdoor.challenge.js
    function setUp() public {
        users.push(alice);
        users.push(bob);
        users.push(charlie);
        users.push(david);

        vm.startPrank(deployer);

        // Deploy Gnosis Safe master copy and factory contracts
        masterCopy = new GnosisSafe();
        walletFactory = new GnosisSafeProxyFactory();
        token = new DamnValuableToken();

        // Deploy the registry
        walletRegistry = new WalletRegistry(address(masterCopy), address(walletFactory), address(token), users);
        require(walletRegistry.owner() == deployer);

        for (uint256 i; i < users.length; ++i) {
            // Users are registered as beneficiaries
            require(walletRegistry.beneficiaries(users[i]) == true);

            // User cannot add beneficiaries
            vm.stopPrank();
            vm.startPrank(users[i]);

            vm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
            walletRegistry.addBeneficiary(users[i]);

            vm.stopPrank();
            vm.startPrank(deployer);
        }

        // Transfer to the registry all of the tokens to be distributed
        token.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);
    }

    function test_Backdoor() public {
        vm.startPrank(player, player);

        Destroyer destroyer = new Destroyer(address(walletRegistry), users, player);
        destroyer.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        for (uint256 i; i < users.length; ++i) {
            address wallet = walletRegistry.wallets(users[i]);

            // User must have registered a wallet
            require(
                wallet != address(0),
                "Sorry, you did not solve the challenge! All users (Alice, Bob, Charlie, David) must have registered a wallet"
            );

            // User is no longer registered as a beneficiary
            require(
                walletRegistry.beneficiaries(users[i]) == false,
                "Sorry, you did not solve the challenge! Alice, Bob, Charlie, and David must no longer be beneficiaries"
            );
        }

        // Player must own all tokens
        require(
            token.balanceOf(player) == AMOUNT_TOKENS_DISTRIBUTED,
            "Sorry, you did not solve the challenge! Player must own all tokens"
        );

        console.log("Congratulations, you solved the challenge! You are a destroyer!!!");
    }

    function test_backdoor() public {
        return test_Backdoor();
    }

    function test_11() public {
        return test_Backdoor();
    }
}
