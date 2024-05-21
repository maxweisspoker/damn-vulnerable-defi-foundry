// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { FlashLoanReceiver } from "../../src/02 - Naive Receiver/FlashLoanReceiver.sol";
import { NaiveReceiverLenderPool } from "../../src/02 - Naive Receiver/NaiveReceiverLenderPool.sol";

// Deploy the challenge in order to practice
contract DeployNaiveReceiverScript is Script {
    function setUp() public { }

    function run() public {
        // You may need to set your private key in vm.startBroadcast(), or use
        // the --private-key and --sender options when running forge script.
        // This deployment requires funding the contracts to set their initial
        // balance.
        vm.startBroadcast();

        NaiveReceiverLenderPool pool = new NaiveReceiverLenderPool();
        (bool s1,) = address(pool).call{ value: 1000 ether }("");
        require(s1, "There was not enough money to create the NaiveReceiverLenderPool");

        FlashLoanReceiver receiver = new FlashLoanReceiver(address(pool));
        (bool s2,) = address(receiver).call{ value: 10 ether }("");
        require(s2, "There was not enough money to create the FlashLoanReceiver");

        vm.stopBroadcast();
        console.log("NaiveReceiverLenderPool address:  ", address(pool));
        console.log("FlashLoanReceiver address:        ", address(receiver));
    }
}
