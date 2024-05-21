// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { ISelfAuthorizedVault } from "../src/15 - ABI Smuggling/Interfaces/ISelfAuthorizedVault.i.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

///////////////////////////////////////////////////////////////////////
import { Smuggler } from "../src/15 - ABI Smuggling/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////////

contract ABISmugglingScript is Script {
    ISelfAuthorizedVault private vault;
    IERC20 private token;

    address private constant vault_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!

    function setUp() public {
        vault = ISelfAuthorizedVault(payable(vault_address));
        token = IERC20(payable(token_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
