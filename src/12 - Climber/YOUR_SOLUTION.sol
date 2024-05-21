// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { IClimberVault } from "./Interfaces/IClimberVault.i.sol";
import { IClimberTimelock } from "./Interfaces/IClimberTimelock.i.sol";
import "./ClimberConstants.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BetterThanTenzingNorgay {
    address private player;
    address private sweeper;
    address private proposer;
    IClimberVault private vault;
    IClimberTimelock private timelock;
    IERC20 private token;

    uint256 private constant VAULT_TOKEN_BALANCE = 10000000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 1e17;
    uint64 private constant TIMELOCK_DELAY = 60 * 60;

    constructor(address _sweeper, address _proposer, address _vault, address _token, address _player) payable {
        sweeper = _sweeper;
        proposer = _proposer;
        vault = IClimberVault(_vault);
        timelock = IClimberTimelock(payable(vault.owner()));
        token = IERC20(_token);
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // As always, make sure to transfer any tokens and ether back to the
        // player account. And as always, feel free to make and use extra
        // functions and/or contracts.

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }

    fallback() external payable { }
}
