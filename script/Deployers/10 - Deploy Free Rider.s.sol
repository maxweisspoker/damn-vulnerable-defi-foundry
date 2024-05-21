// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { FreeRiderRecovery } from "../../src/10 - Free Rider/FreeRiderRecovery.sol";
import { FreeRiderNFTMarketplace } from "../../src/10 - Free Rider/FreeRiderNFTMarketplace.sol";
import { IFreeRiderNFTMarketplace } from "../../src/10 - Free Rider/Interfaces/IFreeRiderNFTMarketplace.i.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { DamnValuableNFT } from "../../src/DamnValuableNFT.sol";
import { IWETH } from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { WethBytecode } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/WethBytecode.sol";
import { UniswapV2Factory } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/UniswapV2Factory.sol";
import { IUniswapV2Factory } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Factory.i.sol";
import { IUniswapV2Pair } from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import { UniswapV2Router02 } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/UniswapV2Router02.sol";
import { IUniswapV2Router02 } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Router02.i.sol";

// Deploy the challenge in order to practice
contract DeployFreeRiderScript is Script {
    uint256[] private tokenIds;
    uint256[] private prices;

    // Broadcast address needs 9090.1 ether plus about a million gas

    // Recovery contract requires deploying with known player address as recovery recipient
    address private PLAYER_ADDRESS = 0x0000000000000000000000000000000000000000; // change me!!!

    uint256 private constant BOUNTY = 45 * 1e18;

    uint256 private constant NFT_PRICE = 15 * 1e18;
    uint256 private constant AMOUNT_OF_NFTS = 6;
    uint256 private constant MARKETPLACE_INITIAL_ETH_BALANCE = 90 * 1e18;

    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 15000 * 1e18;
    uint256 private constant UNISWAP_INITIAL_WETH_RESERVE = 9000 * 1e18;

    function setUp() public { }

    function deployContractFromBytecode(bytes memory bytecode) public returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0)); // 0 = failure to deploy
    }

    function run() public {
        // You may need to set your private key in vm.startBroadcast(), or use
        // the --private-key and --sender options when running forge script.
        // This deployment requires funding the contracts to set their initial
        // balance.
        vm.startBroadcast();

        // Deploy WETH
        // Alternatively, use WETH9 on Ethereum mainnet:
        // IWETH weth = IWETH(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
        WethBytecode wb = new WethBytecode();
        IWETH weth = IWETH(payable(deployContractFromBytecode(wb.WETH_BYTECODE())));

        // Deploy token to be traded against WETH in Uniswap v2
        IERC20 token = IERC20(payable(address(new DamnValuableToken())));

        // Deploy Uniswap Factory and Router
        // Or use Ethereum mainnet addresses:
        // IUniswapV2Factory uniswapFactory = IUniswapV2Factory(payable(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f));
        // IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(payable(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
        IUniswapV2Factory uniswapFactory = IUniswapV2Factory(payable(address(new UniswapV2Factory(address(this)))));
        IUniswapV2Router02 uniswapRouter =
            IUniswapV2Router02(payable(address(new UniswapV2Router02(address(uniswapFactory), address(weth)))));

        token.approve(address(uniswapRouter), UNISWAP_INITIAL_TOKEN_RESERVE);

        uniswapRouter.addLiquidityETH{ value: UNISWAP_INITIAL_WETH_RESERVE }(
            address(token), // token to be traded against WETH
            UNISWAP_INITIAL_TOKEN_RESERVE, // amountTokenDesired
            UNISWAP_INITIAL_TOKEN_RESERVE, // amountTokenMin
            UNISWAP_INITIAL_WETH_RESERVE, // amountETHMin
            address(this), // to
            block.timestamp + 1200 // deadline
        );

        IUniswapV2Pair uniswapPair = IUniswapV2Pair(uniswapFactory.getPair(address(token), address(weth)));

        IFreeRiderNFTMarketplace marketplace = IFreeRiderNFTMarketplace(
            payable(address(new FreeRiderNFTMarketplace{ value: MARKETPLACE_INITIAL_ETH_BALANCE }(AMOUNT_OF_NFTS)))
        );

        DamnValuableNFT nft = DamnValuableNFT(payable(address(marketplace.token())));
        nft.setApprovalForAll(address(marketplace), true);

        for (uint256 i; i < AMOUNT_OF_NFTS; ++i) {
            tokenIds.push(i);
            prices.push(NFT_PRICE);
        }
        marketplace.offerMany(tokenIds, prices);

        // Setup recovery address and fund player with initial 0.1 ether
        FreeRiderRecovery recovery = new FreeRiderRecovery{ value: BOUNTY }(PLAYER_ADDRESS, address(nft));
        PLAYER_ADDRESS.call{ value: 1e17 }("");

        vm.stopBroadcast();

        require(address(weth) != address(0));
        require(address(uniswapFactory) != address(0));
        require(address(uniswapRouter) != address(0));
        require(address(uniswapPair) != address(0));
        require(address(marketplace) != address(0));
        require(address(nft) != address(0));
        require(address(recovery) != address(0));

        require(uniswapPair.token0() == address(token) || uniswapPair.token0() == address(weth));
        require(uniswapPair.token1() == address(token) || uniswapPair.token1() == address(weth));
        require(uniswapPair.token0() != uniswapPair.token1());

        require(nft.owner() == address(0));
        require(nft.rolesOf(address(marketplace)) == nft.MINTER_ROLE());
        require(marketplace.offersCount() == AMOUNT_OF_NFTS);

        console.log("DVT Token address:                 ", address(token));
        console.log("DVT NFT Token address:             ", address(nft));
        console.log("WETH address:                      ", address(weth));
        console.log("Uniswap V2 Factory address:        ", address(uniswapFactory));
        console.log("Uniswap V2 Router02 address:       ", address(uniswapRouter));
        console.log("Uniswap V2 Exchange/Pair address:  ", address(uniswapPair));
        console.log("FreeRiderNFTMarketplace address:   ", address(marketplace));
        console.log("FreeRiderRecovery address:         ", address(recovery));
        console.log("Input player address:              ", PLAYER_ADDRESS);
    }
}
