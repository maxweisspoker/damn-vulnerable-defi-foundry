// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// The player may not have access to the contract code in a real attack situation,
// so we recommend that the player use these interfaces.
import { IUnstoppableVault } from "./Interfaces/IUnstoppableVault.i.sol";
import { IReceiverUnstoppable } from "./Interfaces/IReceiverUnstoppable.i.sol";

import { DamnValuableToken } from "../DamnValuableToken.sol";

// You start with a vault and receiver interface provided to you.
// All the setup has been done for you. You simply need to make sure the
// challenge is solved with the Foundry test running the solveChallenge()
// function.
contract IAmUnstoppable {
    IUnstoppableVault private vault;
    IReceiverUnstoppable private receiver;

    // DVT token contract
    DamnValuableToken private token;

    // "player" will be the EOA deploying this contract, and starts with some DVT tokens
    // That address may be considered like the "owner" of this contract and
    // will be the tx.origin and msg.sender calling the solveChallenge()
    // function.
    address private player;

    uint256 private constant TOKENS_IN_VAULT = 1000000 * 1e18;
    uint256 private constant INITIAL_PLAYER_TOKEN_BALANCE = 10 * 1e18;

    constructor(address _vault, address _receiver, address _player) payable {
        vault = IUnstoppableVault(_vault);
        receiver = IReceiverUnstoppable(_receiver);
        token = DamnValuableToken(vault.asset());
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, this
    // contract is deployed and then this function is run.
    function solveChallenge() public {
        // Although the challenge says the player has 10 DVT tokens, we have
        // modified the test so that this contract has the 10 DVT tokens instead.
        require(token.balanceOf(address(this)) == INITIAL_PLAYER_TOKEN_BALANCE);

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
