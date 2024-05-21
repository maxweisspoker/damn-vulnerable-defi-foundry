// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Taken from:
// https://github.com/pcaversaccio/create-util/blob/346c74b433d5105198933e3281bac449f7ee1b6e/contracts/Create.sol
contract CreateAddressNonce {
    /**
     * @dev Returns the address where a contract will be stored if deployed via `deploy`.
     * For the specification of the Recursive Length Prefix (RLP) encoding scheme, please
     * refer to p. 19 of the Ethereum Yellow Paper (https://ethereum.github.io/yellowpaper/paper.pdf)
     * and the Ethereum Wiki (https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp).
     * For further insights also, see the following issue: https://github.com/transmissions11/solmate/issues/207.
     *
     * Based on the EIP-161 (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md) specification,
     * all contract accounts on the Ethereum mainnet are initiated with `nonce = 1`.
     * Thus, the first contract address created by another contract is calculated with a non-zero nonce.
     */
    // prettier-ignore
    function computeAddress(address addr, uint64 _nonce) public view returns (address) {
        /**
         * @dev The theoretical allowed limit, based on EIP-2681, for an account nonce is 2**64-2:
         * https://eips.ethereum.org/EIPS/eip-2681.
         */
        require(_nonce < 18446744073709551615);
        uint256 nonce = uint256(_nonce);

        bytes memory data;
        bytes1 len = bytes1(0x94);

        /**
         * @dev The integer zero is treated as an empty byte string and therefore has only one
         * length prefix, 0x80, which is calculated via 0x80 + 0.
         */
        if (nonce == 0x00) {
            data = abi.encodePacked(bytes1(0xd6), len, addr, bytes1(0x80));
        }
        /**
         * @dev A one-byte integer in the [0x00, 0x7f] range uses its own value as a length prefix,
         * there is no additional "0x80 + length" prefix that precedes it.
         */
        else if (nonce <= 0x7f) {
            data = abi.encodePacked(bytes1(0xd6), len, addr, uint8(nonce));
        }
        /**
         * @dev In the case of `nonce > 0x7f` and `nonce <= type(uint8).max`, we have the following
         * encoding scheme (the same calculation can be carried over for higher nonce bytes):
         * 0xda = 0xc0 (short RLP prefix) + 0x1a (= the bytes length of: 0x94 + address + 0x84 + nonce, in hex),
         * 0x94 = 0x80 + 0x14 (= the bytes length of an address, 20 bytes, in hex),
         * 0x84 = 0x80 + 0x04 (= the bytes length of the nonce, 4 bytes, in hex).
         */
        else if (nonce <= type(uint8).max) {
            data = abi.encodePacked(bytes1(0xd7), len, addr, bytes1(0x81), uint8(nonce));
        } else if (nonce <= type(uint16).max) {
            data = abi.encodePacked(bytes1(0xd8), len, addr, bytes1(0x82), uint16(nonce));
        } else if (nonce <= type(uint24).max) {
            data = abi.encodePacked(bytes1(0xd9), len, addr, bytes1(0x83), uint24(nonce));
        } else if (nonce <= type(uint32).max) {
            data = abi.encodePacked(bytes1(0xda), len, addr, bytes1(0x84), uint32(nonce));
        } else if (nonce <= type(uint40).max) {
            data = abi.encodePacked(bytes1(0xdb), len, addr, bytes1(0x85), uint40(nonce));
        } else if (nonce <= type(uint48).max) {
            data = abi.encodePacked(bytes1(0xdc), len, addr, bytes1(0x86), uint48(nonce));
        } else if (nonce <= type(uint56).max) {
            data = abi.encodePacked(bytes1(0xdd), len, addr, bytes1(0x87), uint56(nonce));
        } else {
            data = abi.encodePacked(bytes1(0xde), len, addr, bytes1(0x88), uint64(nonce));
        }

        return address(uint160(uint256(keccak256(data))));
    }

    function findAddressNonce(address createAddr, address desiredAddr, uint64 min, uint64 max)
        public
        returns (int128)
    {
        require(max < 18446744073709551615, "The maximum address nonce possible is 2^64 - 2");
        require(min <= max, "Nonce minimum cannot be larger than nonce maximum");
        for (uint64 i = min; i <= max; ++i) {
            if (computeAddress(createAddr, i) == desiredAddr) {
                return int128(uint128(i));
            }
        }
        return -1;
    }
}
