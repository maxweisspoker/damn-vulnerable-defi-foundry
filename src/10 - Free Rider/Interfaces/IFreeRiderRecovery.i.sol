// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect FreeRiderRecovery abi)"
interface IFreeRiderRecovery {
    error CallerNotNFT();
    error InvalidTokenID(uint256 tokenId);
    error NotEnoughFunding();
    error OriginNotBeneficiary();
    error StillNotOwningToken(uint256 tokenId);

    function onERC721Received(address, address, uint256 _tokenId, bytes memory _data) external returns (bytes4);
}
