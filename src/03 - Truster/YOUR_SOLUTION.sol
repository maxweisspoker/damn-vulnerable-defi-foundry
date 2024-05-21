// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// The player may not have access to the TrusterLenderPool contract, so the
// player should use this interface.
import { ITrusterLenderPool } from "./Interfaces/ITrusterLenderPool.i.sol";

import { DamnValuableToken } from "../DamnValuableToken.sol";

contract FasterThanTheFlash {
    address private player;
    ITrusterLenderPool private pool;

    constructor(address _pool, address _player) payable {
        pool = ITrusterLenderPool(payable(_pool));
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // Note that the test to see if you've succeeded is to see if the *player*
        // has all of the tokens. So if you solve the challenge by transferring
        // tokens into this contract, you must then transfer them to the player
        // address, which is provided as a private storage variable in this
        // contract.

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
