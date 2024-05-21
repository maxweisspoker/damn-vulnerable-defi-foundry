// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { FlashLoanReceiver } from "../src/02 - Naive Receiver/FlashLoanReceiver.sol";
import { IFlashLoanReceiver } from "../src/02 - Naive Receiver/Interfaces/IFlashLoanReceiver.i.sol";
import { NaiveReceiverLenderPool } from "../src/02 - Naive Receiver/NaiveReceiverLenderPool.sol";
import { INaiveReceiverLenderPool } from "../src/02 - Naive Receiver/Interfaces/INaiveReceiverLenderPool.i.sol";

//////////////////////////////////////////////////////////////////////////////////////////
import { IAmASharkSwimmingInThePool } from "../src/02 - Naive Receiver/YOUR_SOLUTION.sol";
//////////////////////////////////////////////////////////////////////////////////////////

contract NaiveReceiverTest is Test {
    NaiveReceiverLenderPool private pool;
    FlashLoanReceiver private receiver;

    // Pool has 1000 ETH in balance
    uint256 private constant ETHER_IN_POOL = 1000 * 1e18;

    // Receiver has 10 ETH in balance
    uint256 private constant ETHER_IN_RECEIVER = 10 * 1e18;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Naive receiver deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Naive receiver player")))));
    address private constant user = address(uint160(bytes20(keccak256(abi.encode("Naive receiver user")))));

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/naive-receiver/naive-receiver.challenge.js
    function setUp() public {
        vm.startPrank(deployer);

        pool = new NaiveReceiverLenderPool();
        vm.deal(deployer, ETHER_IN_POOL);
        address(pool).call{ value: ETHER_IN_POOL }("");

        require(address(pool).balance == ETHER_IN_POOL);
        require(pool.maxFlashLoan(pool.ETH()) == ETHER_IN_POOL);
        require(pool.flashFee(pool.ETH(), 0) == 1e18);

        receiver = new FlashLoanReceiver(address(pool));
        vm.deal(deployer, ETHER_IN_RECEIVER);
        address(receiver).call{ value: ETHER_IN_RECEIVER }("");
        address _ETH = pool.ETH();
        // We need to save pool.ETH() to a variable in order to make the onFlashLoan()
        // function be the function tested for a revert.

        // i.e. receiver.onFlashLoan(deployer, pool.ETH(), ETHER_IN_RECEIVER, 1e18, "")
        // will fail the vm.expectRevert() because pool.ETH() is the function tested for revert

        vm.expectRevert();
        receiver.onFlashLoan(deployer, _ETH, ETHER_IN_RECEIVER, 1e18, "");

        require(address(receiver).balance == ETHER_IN_RECEIVER);

        vm.stopPrank();
    }

    function test_NaiveReceiver() public {
        vm.startPrank(player, player);

        IAmASharkSwimmingInThePool shark = new IAmASharkSwimmingInThePool(address(pool), address(receiver));
        shark.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        // All ETH has been drained from the receiver
        require(
            address(receiver).balance == 0, "Sorry, you did not solve the challenge! Receiver should not have funds"
        );
        require(
            address(pool).balance == ETHER_IN_POOL + ETHER_IN_RECEIVER,
            "Sorry, you did not solve the challenge! Pool should have all funds"
        );

        console.log("Congratulations, you solved the challenge! You are a shark in the pool!!!");
    }

    function test_Naive_Receiver() public {
        return test_NaiveReceiver();
    }

    function test_naive_receiver() public {
        return test_NaiveReceiver();
    }

    function test_naivereceiver() public {
        return test_NaiveReceiver();
    }

    function test_02() public {
        return test_NaiveReceiver();
    }
}
