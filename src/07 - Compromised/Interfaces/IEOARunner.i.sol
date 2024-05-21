// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// The "RunAsEOA" function is just a function in the Foundry test file.
// This interface is created solely so that you are restricted in how you
// access and use the test contract, since it would normally not be available.
// Its purpose is simply to allow you to solve the challenge inside the normal
// solveChallenge() function. In the original exercise, you needed to create
// and send separate transactions yourself. By utilizing this function, we
// can let Foundry's cheat codes simulate doing that instead.
interface IEOARunner {
    function RunAsEOA(string calldata privKey, address target, bytes calldata data) external payable returns (bool);

    // The privKey is a 64-character hex string that may or may not be prefixed with "0x".
    // The privKey determines the EOA account used for the transaction.
    // The "target" is which address the EOA account sends the transaction to.
    // The calldata is the calldata attached to the transaction, which can be gotten
    //     with the "abi.encodeWithSignature()" function.
    // You can also send ether/value with the EOA transaction, by adding value in
    //     the call to RunAsEOA(). Either by using the low level call{}() to
    //     execute the RunAsEOA() function, or more easily by calling the
    //     function with the value, like this:  RunAsEOA{ value: 1 ether}(...)
    //     Any value attached to RunAsEOA() will be used in the EOA tx and sent
    //     along to the target address.
    // The function returns true on success and false on a failure or revert.

    // Example usage:
    //     bool success = RunAsEOA{value: 1 ether}("0xE0APrivateKeyHexStr", address(recipient), abi.encodeWithSignature(signatureString, arg));
    //     require(success, "External EOA transaction failed");
}
