// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { WalletRegistry } from "../../src/11 - Backdoor/WalletRegistry.sol";
import { GnosisSafe } from "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import { GnosisSafeProxyFactory } from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";

// Deploy the challenge in order to practice
contract DeployBackdoorScript is Script {
    uint256 private constant AMOUNT_TOKENS_DISTRIBUTED = 40 * 1e18;

    // Arbitrary addresses that we don't need a private key for
    address private constant alice = address(uint160(bytes20(keccak256(abi.encode("Backdoor alice")))));
    address private constant bob = address(uint160(bytes20(keccak256(abi.encode("Backdoor bob")))));
    address private constant charlie = address(uint160(bytes20(keccak256(abi.encode("Backdoor charlie")))));
    address private constant david = address(uint160(bytes20(keccak256(abi.encode("Backdoor david")))));

    address[] private users = [alice, bob, charlie, david];

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        // Alternatively, use Ethereum mainnet GnosisSafe master copy at:
        // 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F
        // GnosisSafe masterCopy = GnosisSafe(0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F)
        GnosisSafe masterCopy = new GnosisSafe();

        // and official proxy factory at:
        // 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B
        // GnosisSafeProxyFactory walletFactory = GnosisSafeProxyFactory(0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B);
        GnosisSafeProxyFactory walletFactory = new GnosisSafeProxyFactory();

        DamnValuableToken token = new DamnValuableToken();

        // Deploy the registry
        WalletRegistry walletRegistry =
            new WalletRegistry(address(masterCopy), address(walletFactory), address(token), users);

        token.transfer(address(walletRegistry), AMOUNT_TOKENS_DISTRIBUTED);

        vm.stopBroadcast();

        require(walletRegistry.owner() == address(this));

        for (uint256 i; i < users.length; ++i) {
            // Users are registered as beneficiaries
            require(walletRegistry.beneficiaries(users[i]) == true);

            // User cannot add beneficiaries
            vm.startPrank(users[i]);

            vm.expectRevert(abi.encodeWithSignature("Unauthorized()"));
            walletRegistry.addBeneficiary(users[i]);

            vm.stopPrank();
        }

        console.log("GnosisSafe master copy address:    ", address(masterCopy));
        console.log("GnosisSafe proxy factory address:  ", address(walletFactory));
        console.log("DVT token address:                 ", address(token));
        console.log("Wallet registry address:           ", address(walletRegistry));
        console.log("Alice:      ", address(alice));
        console.log("Bob:        ", address(bob));
        console.log("Charlie:    ", address(charlie));
        console.log("David:      ", address(david));
    }
}
