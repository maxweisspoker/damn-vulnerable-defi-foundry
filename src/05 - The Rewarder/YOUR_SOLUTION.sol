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

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
