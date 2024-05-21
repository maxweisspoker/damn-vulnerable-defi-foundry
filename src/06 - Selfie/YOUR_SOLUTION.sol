// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// The player may not have access to the original contracts, so the
// player should use these interfaces.
import { ISimpleGovernance } from "./Interfaces/ISimpleGovernance.i.sol";
import { ISelfiePool } from "./Interfaces/ISelfiePool.i.sol";

import { DamnValuableTokenSnapshot } from "../DamnValuableTokenSnapshot.sol";
import { ISleepViaVMWarp } from "./Interfaces/ISleepViaVMWarp.i.sol";

contract OverthrowTheGovernment {
    address private player;
    DamnValuableTokenSnapshot private token;
    ISelfiePool private pool;
    ISimpleGovernance private governance;
    ISleepViaVMWarp private time; // so the function call is time.sleep()

    constructor(
        address _simpleGovernance,
        address _selfiePool,
        address _governanceToken,
        address _sleeper,
        address _player
    ) payable {
        token = DamnValuableTokenSnapshot(_governanceToken);
        pool = ISelfiePool(_selfiePool);
        governance = ISimpleGovernance(_simpleGovernance);
        time = ISleepViaVMWarp(_sleeper);
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // You may or may not need to add additional functions to this contract
        // in order to solve this challenge. You are free to modify this contract
        // however you want; it is your attack contract!

        // Once again, note that any funds or tokens should ultimately end up
        // in the player address in order to pass the challenge.

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
