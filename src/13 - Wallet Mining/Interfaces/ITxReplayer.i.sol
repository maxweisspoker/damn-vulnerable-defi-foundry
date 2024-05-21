// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Important note: This is NOT a generic transaction replayer. It will work
// for most early transactions, and for all the transactions surrounding the
// addresses used in this challenge, but it is iffy at best, so don't go
// trying to use for other things. Seriously, go look at the test file (where
// this contract is located). This thing is very fragile. It's not even a real
// replayer.
interface ITxReplayer {
    function ReplayTransactionFromID(bytes32 txId) external;
    // Does not return anything. Just reverts or doesn't revert. If it doesn't
    // revert, then the tx ID was replayed successfully.
}
