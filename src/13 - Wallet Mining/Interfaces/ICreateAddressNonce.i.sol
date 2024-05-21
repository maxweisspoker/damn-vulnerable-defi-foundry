// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Helper utility to pre-compute the address for a "create" contract deployment,
// or to search for the nonce that would result in a given address. This does
// not work for create2, only create.
interface ICreateAddressNonce {
    // For a given input address and nonce, returns what the address would be
    // if the input address and nonce were used to deploy a new contract with
    // the create (not create2, only create) op code.
    function computeAddress(address createrAddr, uint64 nonce) external returns (address);

    // Finds the nonce that when combined with the createrAddr produces the
    // newContractAddr. The nonce search range is min to max, inclusive. Returns
    // the nonce, or -1 if no nonce is found. Reverts if max is greater than
    // (2^64 - 2) or min > max.
    function findAddressNonce(address createrAddr, address newContractAddr, uint64 min, uint64 max)
        external
        returns (int128 nonce);
    // -1 == not found; any other return value can be cast to uint64 with uint64(uint128(return_value))
}
