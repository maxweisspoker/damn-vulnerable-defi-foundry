// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import { Script, console } from "forge-std/Script.sol";
import { IERC20 } from "../../src/09 - Puppet V2/Interfaces/IERC20.i.sol";
import { IWETH } from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import { PuppetV2Pool } from "../../src/09 - Puppet V2/PuppetV2Pool.sol";
import { UniswapV2Factory } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/UniswapV2Factory.sol";
import { IUniswapV2Pair } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Pair.i.sol";
import { UniswapV2Router02 } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/UniswapV2Router02.sol";
import { IUniswapV2Router02 } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Router02.i.sol";
import { DamnValuableTokenBytecode } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/DamnValuableTokenBytecode.sol";
import { WethBytecode } from "../../src/helpers/uniswap-v2-solc0.6-puppetv2/WethBytecode.sol";

// The boradcast account needs 10 eth (or weth) for the exchange, and another 20
// to fund the player account if you want to do that in this script, as well as
// about a million in gas if you want to deploy weth and uniswap instead of
// using the official already-deployed contracts. Otherwise, ~300k will probably
// suffice for deploying the DVT token and the uniswap exchange/pair contract.

//
// The DVT token needs to be deployed via bytecode due to its Solidity version
// being different from above, so there's some quirks. Make sure to read all
// the comments.
contract DeployPuppetV2TokenScript is Script {
    address private constant YOUR_BROADCAST_ADDRESS_IN_THE_OTHER_DEPLOYSCRIPT =
        0x0000000000000000000000000000000000000000; // change me!!!

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
contract DeployPuppetV2Script is Script {
    address private constant TOKEN_ADDRESS_FROM_ABOVE_DEPLOYMENT = 0x0000000000000000000000000000000000000000; // change me!!!

    // Uniswap v2 exchange will start with 100 tokens and 10 WETH in liquidity
    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 100 * 1e18;
    uint256 private constant UNISWAP_INITIAL_WETH_RESERVE = 10 * 1e18;

    uint256 private constant POOL_INITIAL_TOKEN_BALANCE = 1000000 * 1e18;

    IERC20 private constant token = IERC20(payable(TOKEN_ADDRESS_FROM_ABOVE_DEPLOYMENT));

    function setUp() public { }

    function deployContractFromBytecode(bytes memory bytecode) public returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0)); // 0 = failure to deploy
    }

    function run() public {
        // You may wish to set a private key in the startBroadcast() function in
        // the same way you did in the DVT deployment above, so that you know
        // the broadcast address ahead of time, and have its key in case you
        // leave any tokens or ether in it.
        vm.startBroadcast();

        // Alternatively, you can not use the bytecode and just use the chain's
        // weth address and wrap it in IWETH.
        // Weth on Eth mainnet:  0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        WethBytecode wb = new WethBytecode();
        IWETH weth = IWETH(deployContractFromBytecode(wb.WETH_BYTECODE()));

        // Once again, you can simply use the chain's versions if these are
        // deployed on-chain already. If you do this, you must also use the
        // chain's WETH, because the router address depends on the weth address.
        // Eth mainnet addresses:
        // Uniswap Factory V2:  0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
        // Uniswap Router 02:  0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        UniswapV2Factory uniswapFactory = new UniswapV2Factory(address(this));
        IUniswapV2Router02 uniswapRouter =
            IUniswapV2Router02(new UniswapV2Router02(address(uniswapFactory), address(weth)));

        IUniswapV2Pair uniswapExchange = IUniswapV2Pair(uniswapFactory.createPair(address(token), address(weth)));

        // Be explicit with values to avoid getting MEV'd
        uniswapRouter.addLiquidityETH{ value: UNISWAP_INITIAL_WETH_RESERVE }(
            address(token),
            UNISWAP_INITIAL_TOKEN_RESERVE,
            UNISWAP_INITIAL_TOKEN_RESERVE,
            UNISWAP_INITIAL_WETH_RESERVE,
            address(this),
            block.timestamp + 1200
        );

        PuppetV2Pool lendingPool =
            new PuppetV2Pool(address(weth), address(token), address(uniswapExchange), address(uniswapFactory));

        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);

        //
        // For the challenge, the player starts with 20 eth and 10000 tokens.
        // Set that here if you want to do it now. (You need to set the player
        // address.)

        //address(player).call{value: 20 ether}("");
        //token.transfer(address(player), 10000 * 1e18);

        vm.stopBroadcast();

        console.log("DVT Token address:                 ", address(token));
        console.log("WETH address:                      ", address(weth));
        console.log("Uniswap V2 Factory address:        ", address(uniswapFactory));
        console.log("Uniswap V2 Router02 address:       ", address(uniswapRouter));
        console.log("Uniswap V2 Exchange/Pair address:  ", address(uniswapExchange));
        console.log("Puppet V2 Pool address:            ", address(lendingPool));
    }
}
