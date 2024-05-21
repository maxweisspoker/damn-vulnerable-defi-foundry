// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { IFreeRiderNFTMarketplace } from "../src/10 - Free Rider/Interfaces/IFreeRiderNFTMarketplace.i.sol";
import { IFreeRiderRecovery } from "../src/10 - Free Rider/Interfaces/IFreeRiderRecovery.i.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Factory } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Factory.i.sol";
import { IUniswapV2Pair } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Pair.i.sol";
import { IWETH } from "../src/09 - Puppet V2/Interfaces/IWETH.i.sol";

//////////////////////////////////////////////////////////////////////
import { FreeSpirit } from "../src/10 - Free Rider/YOUR_SOLUTION.sol";
//////////////////////////////////////////////////////////////////////

contract FreeRiderScript is Script {
    IWETH private weth;
    IERC20 private token;
    IERC721 private nft;
    IFreeRiderNFTMarketplace private marketplace;
    IFreeRiderRecovery private recovery;

    address private constant token_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant nft_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant marketplace_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant recovery_address = 0x0000000000000000000000000000000000000000; // change me!!!

    // addresses on Ethereum mainnet
    address private constant weth_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        weth = IWETH(payable(weth_address));
        nft = IERC721(payable(nft_address));
        token = IERC20(payable(token_address));
        marketplace = IFreeRiderNFTMarketplace(payable(marketplace_address));
        recovery = IFreeRiderRecovery(payable(recovery_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
