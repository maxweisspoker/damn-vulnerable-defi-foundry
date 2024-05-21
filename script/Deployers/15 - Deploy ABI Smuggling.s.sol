// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { SelfAuthorizedVault } from "../../src/15 - ABI Smuggling/SelfAuthorizedVault.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Deploy the challenge in order to practice
contract DeployABISmugglingScript is Script {
    uint256 private constant VAULT_TOKEN_BALANCE = 1000000 * 1e18;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        // Deploy Damn Valuable Token contract
        IERC20 token = IERC20(address(new DamnValuableToken()));

        // Deploy Vault
        SelfAuthorizedVault vault = new SelfAuthorizedVault();

        token.transfer(address(vault), VAULT_TOKEN_BALANCE);

        // You must set permissions and initialize the vault before trying
        // the challenge. Look at the test file's setUp() function for this
        // challenge, notably the use of vault.setPermissions() and
        // vault.initialized()

        vm.stopBroadcast();

        console.log("SelfAuthorized Vault address:  ", address(vault));
        console.log("DVT Token address:             ", address(token));
    }
}
