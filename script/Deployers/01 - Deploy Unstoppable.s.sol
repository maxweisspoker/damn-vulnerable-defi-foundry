// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { ERC20 } from "solmate/src/mixins/ERC4626.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { UnstoppableVault } from "../../src/01 - Unstoppable/UnstoppableVault.sol";
import { ReceiverUnstoppable } from "../../src/01 - Unstoppable/ReceiverUnstoppable.sol";

// Deploy the challenge in order to practice
contract DeployUnstoppableScript is Script {
    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        DamnValuableToken dvt = new DamnValuableToken();
        UnstoppableVault vault = new UnstoppableVault(ERC20(address(dvt)), address(this), address(this));
        ReceiverUnstoppable receiver = new ReceiverUnstoppable(address(vault));

        vm.stopBroadcast();

        console.log("UnstoppableVault address:     ", address(vault));
        console.log("ReceiverUnstoppable address:  ", address(receiver));
        console.log("DVT Token address:            ", address(dvt));
    }
}
