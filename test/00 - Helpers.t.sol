// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0; // EthPrivToAddr and StringOperations should work on 0.6, 0.7, and 0.8+
pragma experimental ABIEncoderV2;

import { Test, console } from "forge-std/Test.sol";
import { EthPrivToAddr } from "../src/helpers/EthPrivToAddr.sol";
import { Secp256k1 } from "../src/helpers/Secp256k1.sol";
import { StringOperations } from "../src/helpers/StringOperations.sol";
import { CreateAddressNonce } from "../src/helpers/CreateAddressNonce.sol";

contract HelpersTest is Test {
    EthPrivToAddr private ethPrivToAddr;
    StringOperations private strings;
    CreateAddressNonce private nonceHelper;

    function bytes32ToBytes(bytes32 _input) private pure returns (bytes memory) {
        bytes memory output = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            output[i] = _input[i];
        }
        return output;
    }

    function setUp() public {
        ethPrivToAddr = new EthPrivToAddr();
        strings = new StringOperations();
        nonceHelper = new CreateAddressNonce();
    }

    // Requires "ffi = true" in config or "--ffi" flag when running test
    function test_fuzz_Helpers_EthPrivToAddr(bytes32 privKey) public {
        vm.assume(uint256(privKey) > 1);
        vm.assume(uint256(privKey) < 115792089237316195423570985008687907852837564279074904382605163141518161494337);

        string[] memory command = new string[](4);
        command[0] = "cast";
        command[1] = "wallet";
        command[2] = "address";
        command[3] = strings.iToHex(bytes32ToBytes(privKey));

        bytes memory stdout = vm.ffi(command);

        require(
            keccak256(abi.encode(strings.iToHex(stdout)))
                == keccak256(abi.encode(strings.addressToString(ethPrivToAddr.getAddress(privKey), false, false)))
        );
    }

    function test_fuzz_Helpers_ComputeAddressNonce(address addr, uint64 nonce) public {
        vm.assume(nonce < 18446744073709551615);
        vm.assume(uint160(addr) > 10);
        address guess = nonceHelper.computeAddress(addr, nonce);
        address actual;
        bytes memory bytecode = bytes(hex"3838533838f3"); // Arbitrary small deploy code
        vm.setNonce(addr, nonce);
        vm.startPrank(addr, addr);
        assembly {
            actual := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        vm.stopPrank();
        require(guess == actual);
    }

    function test_fuzz_Helpers_FindAddressNonce(address addr, uint64 nonce) public {
        vm.assume(nonce < 18446744073709551615);
        vm.assume(uint160(addr) > 10);
        bytes memory bytecode = bytes(hex"3838533838f3"); // Arbitrary small deploy code
        address result;
        vm.setNonce(addr, nonce);
        vm.startPrank(addr, addr);
        assembly {
            result := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        vm.stopPrank();
        uint64 start = (nonce > 20) ? nonce - 20 : 0;
        uint64 end = (start < 18446744073709551575) ? start + 40 : 18446744073709551614;
        int128 found = nonceHelper.findAddressNonce(addr, result, start, end);
        require(found != -1);
        require(uint64(uint128(found)) == nonce);
    }
}
