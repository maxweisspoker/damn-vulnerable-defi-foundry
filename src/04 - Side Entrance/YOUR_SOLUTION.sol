// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// The player may not have access to the original contracts, so the
// player should use these interfaces.
import { ISideEntranceLenderPool } from "./Interfaces/ISideEntranceLenderPool.i.sol";
import { IFlashLoanEtherReceiver } from "./Interfaces/IFlashLoanEtherReceiver.i.sol";

contract IAmASidewinder is IFlashLoanEtherReceiver {
    address private player;
    ISideEntranceLenderPool private pool;

    constructor(address _pool, address _player) payable {
        pool = ISideEntranceLenderPool(_pool);
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // You may or may not need to add additional functions to this contract
        // in order to solve this challenge. You are free to modify this contract
        // however you want, it is your attack contract! All the test does is
        // create a new instance of this contract with the constructor args,
        // and then call the solveChallenge(), with the player EOA address
        // as the msg.sender.

        // Any funds or tokens the player started with have been transferred to
        // this contract for your use.

        // But once again, note that the test for solving the challenge checks
        // the player balance, not the contract balance, so you must send funds
        // from this contract to the player address in order to pass.

        // Your code here
    }

    function execute() external payable {
        // Optionally, your code also here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
