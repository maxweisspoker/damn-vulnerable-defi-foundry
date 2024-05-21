// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { IFreeRiderNFTMarketplace } from "./Interfaces/IFreeRiderNFTMarketplace.i.sol";
import { IFreeRiderRecovery } from "./Interfaces/IFreeRiderRecovery.i.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Factory } from "../helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Factory.i.sol";
import { IUniswapV2Pair } from "../helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Pair.i.sol";
import { IWETH } from "../09 - Puppet V2/Interfaces/IWETH.i.sol";

contract FreeSpirit {
    address private player;
    IWETH private weth;
    IERC20 private token;
    IERC721 private nft;
    IUniswapV2Pair private weth_token_pair;
    IFreeRiderNFTMarketplace private marketplace;
    IFreeRiderRecovery private recovery;

    uint256 private constant NFT_PRICE = 15 * 1e18;
    uint256 private constant AMOUNT_OF_NFTS = 6;

    constructor(
        address _weth,
        address _token,
        address _nft,
        address _weth_token_pair,
        address _marketplace,
        address _recovery,
        address _player
    ) payable {
        player = _player;
        weth = IWETH(_weth);
        token = IERC20(_token);
        nft = IERC721(_nft);
        weth_token_pair = IUniswapV2Pair(_weth_token_pair);
        marketplace = IFreeRiderNFTMarketplace(payable(_marketplace));
        recovery = IFreeRiderRecovery(_recovery);
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // The player starts with 0.1 eth, which once again has been trasnferred
        // into this contract for you to use. And as always, any eth and tokens
        // should be sent back to the player account in order to pass the
        // challenge.

        // Additionally, you may or may not need to create extra functions in
        // this contract, or another contract that you deploy from this contract
        // or from the test. As always, you are free to modify this contract to
        // suit your needs and/or create additional contracts.

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
