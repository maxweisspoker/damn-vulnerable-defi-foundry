// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import { Secp256k1 } from "./Secp256k1.sol";

contract EthPrivToAddr {
    function toBytes32(uint256 x) public pure returns (bytes32) {
        return bytes32(x);
    }

    function toPubKeyBytes(bytes32 x, bytes32 y) public pure returns (bytes memory ret) {
        ret = new bytes(64);
        assembly {
            mstore(add(ret, 32), x)
            mstore(add(ret, 64), y)
        }
    }

    function getAddress(bytes32 privateKey) public returns (address) {
        Secp256k1 curve = new Secp256k1();
        (uint256 x, uint256 y) = curve.derivePubKey(uint256(privateKey));
        bytes memory pubKey = toPubKeyBytes(toBytes32(x), toBytes32(y));
        return address(uint160(uint256(uint256(bytes32(keccak256(pubKey))) << 96) >> 96));
    }
}
