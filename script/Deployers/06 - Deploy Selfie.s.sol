// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;
pragma experimental ABIEncoderV2;

import { Script, console } from "forge-std/Script.sol";
import { SelfiePool } from "../../src/06 - Selfie/SelfiePool.sol";
import { SimpleGovernance } from "../../src/06 - Selfie/SimpleGovernance.sol";
import { DamnValuableTokenSnapshot } from "../../src/DamnValuableTokenSnapshot.sol";

// Deploy the challenge in order to practice
contract DeploySelfieScript is Script {
    uint256 private constant TOKEN_INITIAL_SUPPLY = 2000000 * 1e18;
    uint256 private constant TOKENS_IN_POOL = 1500000 * 1e18;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        // Deploy Damn Valuable Token Snapshot
        DamnValuableTokenSnapshot token = new DamnValuableTokenSnapshot(TOKEN_INITIAL_SUPPLY);

        // Deploy governance contract
        SimpleGovernance governance = new SimpleGovernance(address(token));

        // Deploy the pool
        SelfiePool pool = new SelfiePool(address(token), address(governance));

        // Fund the pool
        token.transfer(address(pool), TOKENS_IN_POOL);
        token.snapshot();

        vm.stopBroadcast();

        require(address(pool.token()) == address(token));
        require(address(pool.governance()) == address(governance));
        require(token.balanceOf(address(pool)) == TOKENS_IN_POOL);
        require(pool.maxFlashLoan(address(token)) == TOKENS_IN_POOL);
        require(pool.flashFee(address(token), 0) == 0);

        console.log("DVT Snapshot Token address:  ", address(token));
        console.log("SimpleGovernance address:    ", address(governance));
        console.log("SelfiePool address:          ", address(pool));
    }
}
