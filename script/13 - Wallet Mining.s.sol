// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { IWalletDeployer } from "../src/13 - Wallet Mining/Interfaces/IWalletDeployer.i.sol";
import { IAuthorizerUpgradeable } from "../src/13 - Wallet Mining/Interfaces/IAuthorizerUpgradeable.i.sol";
import { IGnosisSafeProxyFactory } from "../src/13 - Wallet Mining/Interfaces/IGnosisSafeProxyFactory.i.sol";
import { IGnosisSafe } from "../src/13 - Wallet Mining/Interfaces/IGnosisSafe.i.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC1967Utils } from
    "openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

/////////////////////////////////////////////////////////////////////////
import { GoldStrike } from "../src/13 - Wallet Mining/YOUR_SOLUTION.sol";
/////////////////////////////////////////////////////////////////////////

contract WalletMiningScript is Script {
    IAuthorizerUpgradeable private authorizer;
    IERC20 private token;
    IWalletDeployer private walletDeployer;

    address private constant authorizer_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant walletDeployer_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!

    address[] private wards = [
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000 // change me!!!
    ];
    address[] private aims = [
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000, // change me!!!
        0x0000000000000000000000000000000000000000 // change me!!!
    ];

    function setUp() public {
        authorizer = IAuthorizerUpgradeable(payable(authorizer_address));
        walletDeployer = IWalletDeployer(payable(walletDeployer_address));
        token = IERC20(payable(token_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
