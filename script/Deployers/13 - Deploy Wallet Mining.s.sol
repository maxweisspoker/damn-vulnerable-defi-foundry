// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { ERC1967Proxy } from
    "openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { AuthorizerUpgradeable } from "../../src/13 - Wallet Mining/AuthorizerUpgradeable.sol";
import { IAuthorizerUpgradeable } from "../../src/13 - Wallet Mining/Interfaces/IAuthorizerUpgradeable.i.sol";
import { WalletDeployer } from "../../src/13 - Wallet Mining/WalletDeployer.sol";

// Deploy the challenge in order to practice
contract DeployWalletMiningScript is Script {
    address[] private wards;
    address[] private aims;

    address private constant DEPOSIT_ADDRESS = 0x9B6fb606A9f5789444c17768c6dFCF2f83563801;
    uint256 private constant DEPOSIT_TOKEN_AMOUNT = 20000000 * 1e18;

    // Arbitrary address we don't need the key for
    address private constant ward = address(uint160(bytes20(keccak256(abi.encode("Wallet Mining ward")))));

    function setUp() public {
        wards.push(ward);
        aims.push(DEPOSIT_ADDRESS);
    }

    function run() public {
        vm.startBroadcast();

        // Deploy Damn Valuable Token contract
        DamnValuableToken token = new DamnValuableToken();

        // Deploy authorizer with the corresponding proxy
        address authorizer_logicContract = address(new AuthorizerUpgradeable());
        IAuthorizerUpgradeable authorizer = IAuthorizerUpgradeable(
            address(
                new ERC1967Proxy(
                    authorizer_logicContract, abi.encodeWithSignature("init(address[],address[])", wards, aims)
                )
            )
        );

        // Deploy Safe Deployer contract
        WalletDeployer walletDeployer = new WalletDeployer(address(token));

        // Set Authorizer in Safe Deployer
        walletDeployer.rule(address(authorizer));

        // Fund Safe Deployer with tokens
        token.transfer(address(walletDeployer), walletDeployer.pay() * 43);

        // Deposit large amount of DVT tokens to the deposit address
        token.transfer(DEPOSIT_ADDRESS, DEPOSIT_TOKEN_AMOUNT);

        vm.stopBroadcast();

        require(authorizer.owner() == address(this));
        require(authorizer.can(ward, DEPOSIT_ADDRESS));
        require(walletDeployer.chief() == address(this));
        require(walletDeployer.gem() == address(token));
        require(walletDeployer.mom() == address(authorizer));
        require(token.balanceOf(DEPOSIT_ADDRESS) == DEPOSIT_TOKEN_AMOUNT);
        require(token.balanceOf(address(walletDeployer)) == walletDeployer.pay() * 43);

        console.log("AuthorizerUpgradeable logic contract:  ", authorizer_logicContract);
        console.log("AuthorizerUpgradeable proxy address:   ", address(authorizer));
        console.log("Wallet Deployer address:   ", address(walletDeployer));
        console.log("DVT Token address:         ", address(token));
    }
}
