// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// Created by running "cast interface <(forge inspect Exchange abi)"
interface IExchange {
    error InvalidPayment();
    error NotEnoughFunds();
    error SellerNotOwner(uint256 id);
    error TransferNotApproved();

    event TokenBought(address indexed buyer, uint256 tokenId, uint256 price);
    event TokenSold(address indexed seller, uint256 tokenId, uint256 price);

    receive() external payable;

    function buyOne() external payable returns (uint256 id);
    function oracle() external view returns (address);
    function sellOne(uint256 id) external;
    function token() external view returns (address);
}
