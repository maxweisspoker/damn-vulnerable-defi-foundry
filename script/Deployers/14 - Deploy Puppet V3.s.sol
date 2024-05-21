// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import { Script, console } from "forge-std/Script.sol";
import { PuppetV3Pool } from "../../src/14 - Puppet V3/PuppetV3Pool.sol";
import { DamnValuableTokenBytecode } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/DamnValuableTokenBytecode.sol";
import { IERC20 } from "../../src/09 - Puppet V2/Interfaces/IERC20.i.sol";
import { WethBytecode } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/WethBytecode.sol";
import { IWETH } from "../../src/09 - Puppet V2/Interfaces/IWETH.i.sol";
import { UniswapV3Factory } from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import { IUniswapV3Factory } from "../../src/helpers/uniswap-v3-abi-and-bytecode/IUniswapV3Factory.i.sol";
import { UniswapV3SwapRouterBytecode } from
    "../../src/helpers/uniswap-v3-abi-and-bytecode/UniswapV3SwapRouterBytecode.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { TokenDescriptorBytecode } from "../../src/helpers/uniswap-v3-abi-and-bytecode/TokenDescriptorBytecode.sol";
import { NonfungiblePositionManagerBytecode } from
    "../../src/helpers/uniswap-v3-abi-and-bytecode/NonfungiblePositionManagerBytecode.sol";
import { INonfungiblePositionManager } from
    "../../src/helpers/uniswap-v3-abi-and-bytecode/INonfungiblePositionManager.i.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { IERC20Minimal } from "@uniswap/v3-core/contracts/interfaces/IERC20Minimal.sol";
import { Math } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/Math.sol";

//
// Just like for Puppet V2, the DVT token needs to be deployed via bytecode due
// to its Solidity version being different from above, so there's some quirks.
// Make sure to read all the comments.
contract DeployPuppetV2TokenScript is Script {
    address private constant YOUR_BROADCAST_ADDRESS_IN_THE_OTHER_DEPLOYSCRIPT =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // change me if you use a different private key

    function setUp() public { }

    function deployContractFromBytecode(bytes memory bytecode) public returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0)); // 0 = failure to deploy
    }

    // Read ALL of the comments in this function!
    function run() public {
        // You should have about a half a million gas available, although the
        // deployment should only cost 200k-300k.

        // example: hex"25c61974def4c8af535255b6a75f5c1873b496093b8deffde2418061d9106ad1"
        // should be 64 hex chars, does not start with 0x
        // see "IMPORTANT!!!" note below
        vm.startBroadcast(
            uint256(bytes32(hex"25c61974def4c8af535255b6a75f5c1873b496093b8deffde2418061d9106ad1")) // change me!!!
        ); // replace 25c61974def4c8af535255b6a75f5c1873b496093b8deffde2418061d9106ad1 with
        //    the private key for the address that the token was minted to!

        // DVT token needs to be deployed via bytecode because the solidity
        // code requires version ^0.8.0, so we can't compile it for use with
        // this test (which requires solidity 0.6.6).

        // IMPORTANT!!! You must modify the bytecode to mint to an address that
        // you control. Search and replace the text "107523153d966ae672ee6fe58cf3f3611d223edf"
        // with an address that you control the private key for. It begins at
        // the 297th character (149th byte) of the DVT bytecode in the
        // "src/helpers/uniswap-v2-solc0.6-puppetv2/DamnValuableTokenBytecode.sol"
        // file. Then use the private key for that address in the startBroadcast()
        // function above.

        DamnValuableTokenBytecode dvb = new DamnValuableTokenBytecode();
        IERC20 token = IERC20(deployContractFromBytecode(dvb.DAMN_VALUABLE_BYTECODE()));

        token.transfer(YOUR_BROADCAST_ADDRESS_IN_THE_OTHER_DEPLOYSCRIPT, token.totalSupply());

        vm.stopBroadcast();

        console.log("DVT Token address:  ", address(token));
    }
}

// Deploy the challenge in order to practice
contract DeployPuppetV3Script is Script {
    WethBytecode private wb;
    NonfungiblePositionManagerBytecode private npmb;
    UniswapV3SwapRouterBytecode private srbc;
    TokenDescriptorBytecode private nftpdbc;

    address private constant TOKEN_ADDRESS_FROM_ABOVE_DEPLOYMENT = 0x0000000000000000000000000000000000000000; // change me!!!
    IERC20 private token = IERC20(payable(TOKEN_ADDRESS_FROM_ABOVE_DEPLOYMENT));

    uint256 private constant UNISWAP_INITIAL_TOKEN_LIQUIDITY = 100 * 1e18;
    uint256 private constant UNISWAP_INITIAL_WETH_LIQUIDITY = 100 * 1e18;

    uint256 private constant LENDING_POOL_INITIAL_TOKEN_BALANCE = 1000000 * 1e18;

    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 110 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 1e18;

    uint24 private constant FEE = 3000;

    function getBytecodeSize(address deployedContract) public view returns (uint256 size) {
        assembly {
            size := extcodesize(deployedContract)
        }
    }

    function deployContractFromBytecode(bytes memory bytecode) public returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0)); // 0 = failure to deploy
    }

    function encodePriceSqrt(uint256 reserve0, uint256 reserve1) public pure returns (uint160) {
        require(reserve0 != 0);
        require(reserve1 != 0);
        return uint160(uint256(Math.sqrt(reserve1 / reserve0) * (2 ** 96)));
    }

    function setUp() public {
        wb = new WethBytecode();
        npmb = new NonfungiblePositionManagerBytecode();
        srbc = new UniswapV3SwapRouterBytecode();
        nftpdbc = new TokenDescriptorBytecode();
    }

    // Broadcast account needs about 212 ether plus about a million gas
    function run() public {
        // Deploy using account #1 in Hardhat's node
        // Change private key if you want to use a different one.
        // If you do that, make sure to change the YOUR_BROADCAST_ADDRESS_IN_THE_OTHER_DEPLOYSCRIPT
        // variable in the above contract to the right address.
        vm.startBroadcast(uint256(bytes32(hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80")));
        address deployer = msg.sender;

        IUniswapV3Factory uniswapFactory = IUniswapV3Factory(payable(address(new UniswapV3Factory())));

        IWETH weth = IWETH(payable(deployContractFromBytecode(wb.WETH_BYTECODE())));

        ISwapRouter swapRouter = ISwapRouter(
            deployContractFromBytecode(
                srbc.UNISWAP_V3_SWAPROUTER_BYTECODE_MODIFIABLE(address(uniswapFactory), address(weth))
            )
        );

        address nftpd =
            deployContractFromBytecode(nftpdbc.UNISWAP_V3_TOKEN_DESCRIPTOR_BYTECODE_MODIFIABLE(address(weth)));

        INonfungiblePositionManager nftpm = INonfungiblePositionManager(
            payable(
                deployContractFromBytecode(
                    npmb.UNISWAP_V3_POSITION_MANAGER_BYTECODE_MODIFIABLE(address(uniswapFactory), address(weth), nftpd)
                )
            )
        );

        nftpm.createAndInitializePoolIfNecessary{ gas: 5000000 }(
            address(token), address(weth), FEE, encodePriceSqrt(1, 1)
        );

        IUniswapV3Pool uniswapPool = IUniswapV3Pool(payable(uniswapFactory.getPool(address(weth), address(token), FEE)));

        uniswapPool.increaseObservationCardinalityNext(40);

        weth.deposit{ value: UNISWAP_INITIAL_WETH_LIQUIDITY }();
        weth.approve(address(nftpm), type(uint256).max);
        token.approve(address(nftpm), type(uint256).max);
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: address(token),
            token1: address(weth),
            tickLower: -60,
            tickUpper: 60,
            fee: FEE,
            recipient: deployer,
            amount0Desired: UNISWAP_INITIAL_WETH_LIQUIDITY,
            amount1Desired: UNISWAP_INITIAL_TOKEN_LIQUIDITY,
            amount0Min: UNISWAP_INITIAL_WETH_LIQUIDITY,
            amount1Min: UNISWAP_INITIAL_TOKEN_LIQUIDITY,
            deadline: block.timestamp + 1200
        });
        nftpm.mint{ gas: 5000000 }(params);

        PuppetV3Pool lendingPool =
            new PuppetV3Pool(IERC20Minimal(address(token)), IERC20Minimal(address(weth)), uniswapPool);

        token.transfer(address(lendingPool), LENDING_POOL_INITIAL_TOKEN_BALANCE);

        // to fund the player account, set the player address and uncomment
        //address(player).call{value: PLAYER_INITIAL_ETH_BALANCE}("");
        //token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);

        vm.stopBroadcast();

        require(token.balanceOf(deployer) > 0);
        require(lendingPool.calculateDepositOfWETHRequired(1e18) == 3e18);
        require(
            lendingPool.calculateDepositOfWETHRequired(LENDING_POOL_INITIAL_TOKEN_BALANCE)
                == LENDING_POOL_INITIAL_TOKEN_BALANCE * 3
        );

        console.log("Uniswap V3 Factory address:           ", address(uniswapFactory));
        console.log("Uniswap V3 Swap Router address:       ", address(swapRouter));
        console.log("Uniswap V3 Token Descriptor address:  ", address(nftpd));
        console.log("Uniswap V3 Position Manager address:  ", address(nftpm));
        console.log("Uniswap V3 Token/Weth Pool address:   ", address(uniswapPool));
        console.log("Puppet Pool V3 address:  ", address(lendingPool));
        console.log("DVT Token address:       ", address(token));
        console.log("WETH address:            ", address(weth));
    }
}
