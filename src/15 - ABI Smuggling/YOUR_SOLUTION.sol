// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { ISelfAuthorizedVault } from "./Interfaces/ISelfAuthorizedVault.i.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Smuggler {
    ISelfAuthorizedVault private vault;
    IERC20 private token;
    address private recovery;
    address private player;

    constructor(address _vault, address _token, address _recovery, address _player) {
        vault = ISelfAuthorizedVault(_vault);
        token = IERC20(_token);
        recovery = _recovery;
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // The player does not start with any funds, and the result of this
        // challenge should be to send tokens to the recovery address, so there
        // is no need to worry about transferring funds to or from the player
        // account.

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
