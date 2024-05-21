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

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // The UnstoppableVault contract function flashLoan() contains the following
        // two lines of code:
        //     uint256 balanceBefore = totalAssets();
        //     if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance();

        // The totalAssets() function contains the line:
        //    return asset.balanceOf(address(this));
        // And the convertToShares() function is defined as:
        //    uint256 supply = totalSupply;
        //    return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
        // where the totalSupply and assets are both the total number of minted
        // tokens, and supply is the number of tokens in the vault.

        // Because the asset supply information is only changed when the
        // deposit and withdraw functions are called, we can change the actual
        // amount of tokens in the vault by simply doing a direct transfer.
        // This will alter the "return asset.balanceOf(address(this))" return
        // value in the totalAssets() function, which allows us to change both
        // the convertToShares() function as well as the "balanceBefore" variable
        // which gets set via the totalAssets() function.

        // If we look at the way that the convertToShares() function works, the
        // math is:  (assets * supply) / totalAssets()
        // Therefore if we add tokens to the contract with the transfer function,
        // which doesn't update the supply, we can increase the denominator
        // of that math function and reduce the returned result. Additionally,
        // by transfering tokens into the contract, we increase "balanceBefore"
        // variable, since it is set via the totalAssets() function. The decrease
        // in the convertToShares() returned value, as well as the increase in
        // the "balanceBefore" variable, should cause the statement:
        //    if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance();
        // to fail and call the "revert InvalidBalance()".

        // And because nobody can decrease the amount of tokens from the contract
        // (because they would not have approval), the contract can only be
        // manipulated to add more tokens, which would still cause the revert.
        // This means we should be able to solve the challenge by simply transfering
        // DVT tokens into the vault via ERC20 transfer(), bypassing the deposit()
        // method.

        token.transfer(address(vault), token.balanceOf(address(this)));

        // Youtube walkthroughs:
        // https://www.youtube.com/watch?v=SssTj52WYNM
        // https://www.youtube.com/watch?v=th8U1R29KW0
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
