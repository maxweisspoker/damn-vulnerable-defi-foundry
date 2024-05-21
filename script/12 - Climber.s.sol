// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { IClimberVault } from "../src/12 - Climber/Interfaces/IClimberVault.i.sol";
import { IClimberTimelock } from "../src/12 - Climber/Interfaces/IClimberTimelock.i.sol";
import "../src/12 - Climber/ClimberConstants.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

////////////////////////////////////////////////////////////////////////////////
import { BetterThanTenzingNorgay } from "../src/12 - Climber/YOUR_SOLUTION.sol";
////////////////////////////////////////////////////////////////////////////////

contract ClimberScript is Script {
    IClimberVault private vault;
    IClimberTimelock private timelock;
    IERC20 private token;

    address payable private constant sweeper = payable(0x0000000000000000000000000000000000000000); // change me!!!
    address payable private constant proposer = payable(0x0000000000000000000000000000000000000000); // change me!!!

    address private constant vault_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant timelock_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!

    function setUp() public {
        vault = IClimberVault(payable(vault_address));
        timelock = IClimberTimelock(payable(timelock_address));
        token = IERC20(payable(token_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
