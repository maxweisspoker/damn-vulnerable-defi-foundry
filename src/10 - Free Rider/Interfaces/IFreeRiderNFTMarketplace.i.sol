// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect FreeRiderNFTMarketplace abi)"
interface IFreeRiderNFTMarketplace {
    error CallerNotOwner(uint256 tokenId);
    error InsufficientPayment();
    error InvalidApproval();
    error InvalidPrice();
    error InvalidPricesAmount();
    error InvalidTokensAmount();
    error TokenNotOffered(uint256 tokenId);

    event NFTBought(address indexed buyer, uint256 tokenId, uint256 price);
    event NFTOffered(address indexed offerer, uint256 tokenId, uint256 price);

    receive() external payable;

    function buyMany(uint256[] memory tokenIds) external payable;
    function offerMany(uint256[] memory tokenIds, uint256[] memory prices) external;
    function offersCount() external view returns (uint256);
    function token() external view returns (address);
}
