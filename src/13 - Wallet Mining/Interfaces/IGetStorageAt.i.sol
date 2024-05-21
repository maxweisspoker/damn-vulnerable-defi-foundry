// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

interface IGetStorageAt {
    function GetStorageAtSlot(address addr, bytes32 slot) external returns (bytes32);
}
