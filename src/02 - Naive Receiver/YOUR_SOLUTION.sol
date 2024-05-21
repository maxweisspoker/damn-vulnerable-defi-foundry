// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// The player may not have access to the contracts, so the player
// should use these interfaces.
import { IFlashLoanReceiver } from "./Interfaces/IFlashLoanReceiver.i.sol";
import { INaiveReceiverLenderPool } from "./Interfaces/INaiveReceiverLenderPool.i.sol";

// You start with a pool and receiver interface provided to you.
// All the setup has been done for you. You simply need to make sure the
// challenge is solved with the Foundry test running the solveChallenge()
// function.
contract IAmASharkSwimmingInThePool {
    INaiveReceiverLenderPool private pool;
    IFlashLoanReceiver private receiver;

    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address _pool, address _receiver) payable {
        pool = INaiveReceiverLenderPool(payable(_pool));
        receiver = IFlashLoanReceiver(payable(_receiver));
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
