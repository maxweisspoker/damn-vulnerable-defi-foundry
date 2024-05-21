// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { AccountingToken } from "../../src/05 - The Rewarder/AccountingToken.sol";
import { FlashLoanerPool } from "../../src/05 - The Rewarder/FlashLoanerPool.sol";
import { RewardToken } from "../../src/05 - The Rewarder/RewardToken.sol";
import { TheRewarderPool } from "../../src/05 - The Rewarder/TheRewarderPool.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";

// Deploy the challenge in order to practice
contract DeployTheRewarderScript is Script {
    uint256 private constant TOKENS_IN_LENDER_POOL = 1000000 * 1e18;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        DamnValuableToken liquidityToken = new DamnValuableToken();
        FlashLoanerPool flashLoanPool = new FlashLoanerPool(address(liquidityToken));
        liquidityToken.transfer(address(flashLoanPool), TOKENS_IN_LENDER_POOL);
        TheRewarderPool rewarderPool = new TheRewarderPool(address(liquidityToken));

        vm.stopBroadcast();

        console.log("DamnValuableToken address:  ", address(liquidityToken));
        console.log("AccountingToken address:    ", address(rewarderPool.accountingToken()));
        console.log("RewardToken address:        ", address(rewarderPool.rewardToken()));
        console.log("FlashLoanerPool address:    ", address(flashLoanPool));
        console.log("TheRewarderPool address:    ", address(rewarderPool));
    }
}
