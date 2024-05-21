// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { SideEntranceLenderPool } from "../../src/04 - Side Entrance/SideEntranceLenderPool.sol";

// Deploy the challenge in order to practice
contract DeploySideEntranceScript is Script {
    function setUp() public { }

    function run() public {
        // You may need to set your private key in vm.startBroadcast(), or use
        // the --private-key and --sender options when running forge script.
        // This deployment requires funding the contract to set its initial
        // balance.
        vm.startBroadcast();

        SideEntranceLenderPool pool = new SideEntranceLenderPool();
        pool.deposit{ value: 1000 ether }();
        require(address(pool).balance == 1000 ether, "Not enough money to fund SideEntranceLenderPool");

        // Note: If you used your account to fund the pool you should use a
        // different account to try to solve the challenge, since the pool
        // deposit is credited to your funding account.

        vm.stopBroadcast();
        console.log("SideEntranceLenderPool address:  ", address(pool));
    }
}
