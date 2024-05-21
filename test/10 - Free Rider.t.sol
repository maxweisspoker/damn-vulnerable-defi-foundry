// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { FreeRiderRecovery } from "../src/10 - Free Rider/FreeRiderRecovery.sol";
import { FreeRiderNFTMarketplace } from "../src/10 - Free Rider/FreeRiderNFTMarketplace.sol";
import { IWETH } from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import { WethBytecode } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/WethBytecode.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";
import { DamnValuableNFT } from "../src/DamnValuableNFT.sol";
import { UniswapV2Factory } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/UniswapV2Factory.sol";
import { IUniswapV2Pair } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import { UniswapV2Router02 } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/UniswapV2Router02.sol";

//////////////////////////////////////////////////////////////////////
import { FreeSpirit } from "../src/10 - Free Rider/YOUR_SOLUTION.sol";
//////////////////////////////////////////////////////////////////////

contract FreeRiderTest is Test {
    uint256[] private tokenIds;
    uint256[] private prices;
    IWETH private weth;
    DamnValuableToken private token;
    DamnValuableNFT private nft;
    UniswapV2Factory private uniswapFactory;
    IUniswapV2Pair private uniswapPair;
    UniswapV2Router02 private uniswapRouter;
    FreeRiderNFTMarketplace private marketplace;
    FreeRiderRecovery private devsContract;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("FreeRider deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("FreeRider player")))));
    address private constant devs = address(uint160(bytes20(keccak256(abi.encode("FreeRider devs")))));

    // The NFT marketplace will have 6 tokens, at 15 ETH each
    uint256 private constant NFT_PRICE = 15 * 1e18;
    uint256 private constant AMOUNT_OF_NFTS = 6;
    uint256 private constant MARKETPLACE_INITIAL_ETH_BALANCE = 90 * 1e18;

    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 1e17;
    uint256 private constant BOUNTY = 45 * 1e18;

    // Initial reserves for the Uniswap v2 pool
    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 15000 * 1e18;
    uint256 private constant UNISWAP_INITIAL_WETH_RESERVE = 9000 * 1e18;

    function deployContractFromBytecode(bytes memory bytecode) public returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0)); // 0 = failure to deploy
    }

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/free-rider/free-rider.challenge.js
    function setUp() public {
        vm.startPrank(deployer);

        // Player starts with limited ETH balance
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        require(player.balance == PLAYER_INITIAL_ETH_BALANCE);

        // Deploy WETH
        WethBytecode wb = new WethBytecode();
        weth = IWETH(deployContractFromBytecode(wb.WETH_BYTECODE()));

        // Deploy token to be traded against WETH in Uniswap v2
        token = new DamnValuableToken();

        // Deploy Uniswap Factory and Route
        uniswapFactory = new UniswapV2Factory(deployer);
        uniswapRouter = new UniswapV2Router02(address(uniswapFactory), address(weth));

        // Approve tokens, and then create Uniswap v2 pair against WETH and add liquidity.
        // The addLiquidityETH() function takes care of deploying the pair automatically.
        vm.deal(deployer, UNISWAP_INITIAL_WETH_RESERVE);
        token.approve(address(uniswapRouter), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapRouter.addLiquidityETH{ value: UNISWAP_INITIAL_WETH_RESERVE }(
            address(token), // token to be traded against WETH
            UNISWAP_INITIAL_TOKEN_RESERVE, // amountTokenDesired
            0, // amountTokenMin
            0, // amountETHMin
            deployer, // to
            block.timestamp * 2 // deadline
        );

        // Get a reference to the created Uniswap pair, and do some checks
        uniswapPair = IUniswapV2Pair(uniswapFactory.getPair(address(token), address(weth)));
        require(address(uniswapPair) != address(0));
        require(uniswapPair.token0() == address(token) || uniswapPair.token0() == address(weth));
        require(uniswapPair.token1() == address(token) || uniswapPair.token1() == address(weth));
        require(uniswapPair.token0() != uniswapPair.token1());
        require(uniswapPair.balanceOf(deployer) > 0);

        // Deploy the marketplace and get the associated ERC721 token
        // The marketplace will automatically mint AMOUNT_OF_NFTS to the deployer (see `FreeRiderNFTMarketplace::constructor`)
        vm.deal(deployer, MARKETPLACE_INITIAL_ETH_BALANCE);
        marketplace = new FreeRiderNFTMarketplace{ value: MARKETPLACE_INITIAL_ETH_BALANCE }(AMOUNT_OF_NFTS);

        // Deploy NFT contract
        nft = marketplace.token();
        require(nft.owner() == address(0));
        require(nft.rolesOf(address(marketplace)) == nft.MINTER_ROLE());

        // Ensure deployer owns all minted NFTs. Then approve the marketplace to trade them.
        for (uint256 id; id < AMOUNT_OF_NFTS; ++id) {
            require(nft.ownerOf(id) == deployer);
        }
        nft.setApprovalForAll(address(marketplace), true);

        for (uint256 i; i < AMOUNT_OF_NFTS; ++i) {
            tokenIds.push(i);
            prices.push(NFT_PRICE);
        }
        marketplace.offerMany(tokenIds, prices);
        require(marketplace.offersCount() == 6);

        vm.stopPrank();
        vm.startPrank(devs);

        vm.deal(devs, BOUNTY);
        devsContract = new FreeRiderRecovery{ value: BOUNTY }(player, address(nft));

        vm.stopPrank();
    }

    function test_FreeRider() public {
        vm.startPrank(player, player);

        FreeSpirit freeSpirit = new FreeSpirit{ value: player.balance }(
            address(weth),
            address(token),
            address(nft),
            address(uniswapPair),
            address(marketplace),
            address(devsContract),
            player
        );
        freeSpirit.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        vm.startPrank(devs);

        // The devs extract all NFTs from its associated contract
        for (uint256 tokenId; tokenId < AMOUNT_OF_NFTS; ++tokenId) {
            nft.transferFrom(address(devsContract), devs, tokenId);
            require(nft.ownerOf(tokenId) == devs);
        }

        vm.stopPrank();

        // Exchange must have lost NFTs and ETH
        require(
            marketplace.offersCount() == 0, "Sorry, you did not solve the challenge! Exchange must have lost all NFTs"
        );
        require(
            address(marketplace).balance < MARKETPLACE_INITIAL_ETH_BALANCE,
            "Sorry, you did not solve the challenge! Exchange must have lost ETH"
        );

        // Player must have earned all ETH
        require(player.balance > BOUNTY, "Sorry, you did not solve the challenge! Player must have earned all ETH");
        require(
            address(devsContract).balance == 0,
            "Sorry, you did not solve the challenge! Dev recovery contract must not have any ETH"
        );

        console.log("Congratulations, you solved the challenge! You truly are a free spirit!!!");
    }

    function test_Free_Rider() public {
        return test_FreeRider();
    }

    function test_freerider() public {
        return test_FreeRider();
    }

    function test_free_rider() public {
        return test_FreeRider();
    }

    function test_10() public {
        return test_FreeRider();
    }
}
