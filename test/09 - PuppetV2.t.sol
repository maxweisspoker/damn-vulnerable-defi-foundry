// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import { Test, console } from "forge-std/Test.sol";
import { IERC20 } from "../src/09 - Puppet V2/Interfaces/IERC20.i.sol";
import { IWETH } from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import { PuppetV2Pool } from "../src/09 - Puppet V2/PuppetV2Pool.sol";
import { UniswapV2Factory } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/UniswapV2Factory.sol";
import { IUniswapV2Pair } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Pair.i.sol";
import { UniswapV2Router02 } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/UniswapV2Router02.sol";
import { IUniswapV2Router02 } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Router02.i.sol";
import { DamnValuableTokenBytecode } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/DamnValuableTokenBytecode.sol";
import { WethBytecode } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/WethBytecode.sol";
import { StringOperations } from "../src/helpers/StringOperations.sol";

/////////////////////////////////////////////////////////////////////////
import { PuppetMasterV2 } from "../src/09 - Puppet V2/YOUR_SOLUTION.sol";
/////////////////////////////////////////////////////////////////////////

contract PuppetV2Test is Test {
    PuppetV2Pool private lendingPool;
    IERC20 private token;
    IWETH private weth;
    UniswapV2Factory private uniswapFactory;
    IUniswapV2Pair private uniswapExchange;
    IUniswapV2Router02 private uniswapRouter;
    StringOperations private strings;

    // Uniswap v2 exchange will start with 100 tokens and 10 WETH in liquidity
    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 100 * 1e18;
    uint256 private constant UNISWAP_INITIAL_WETH_RESERVE = 10 * 1e18;

    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 10000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 20 * 1e18;

    uint256 private constant POOL_INITIAL_TOKEN_BALANCE = 1000000 * 1e18;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("PuppetV2 deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("PuppetV2 player")))));

    // DVT deploy bytecode was modified to mint to this constant address
    address private constant dvt_minter = address(uint160(bytes20(keccak256(abi.encode("Damn Valuable Token Owner")))));

    function deployContractFromBytecode(bytes memory bytecode) public returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0)); // 0 = failure to deploy
    }

    // Partial re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/puppet-v2/puppet-v2.challenge.js
    function setUp() public {
        strings = new StringOperations();

        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        require(player.balance == PLAYER_INITIAL_ETH_BALANCE);

        vm.deal(deployer, UNISWAP_INITIAL_WETH_RESERVE);
        require(deployer.balance == UNISWAP_INITIAL_WETH_RESERVE);

        vm.startPrank(deployer);

        // DVT token needs to be deployed via bytecode because the solidity
        // code requires version ^0.8.0, so we can't compile it for use with
        // this test (which requires solidity 0.6.6).
        DamnValuableTokenBytecode dvb = new DamnValuableTokenBytecode();
        token = IERC20(deployContractFromBytecode(dvb.DAMN_VALUABLE_BYTECODE()));

        // Weth deployed by bytecode because why not.
        // This is the actual mainnet deployed bytecode, taken right from the blockchain
        WethBytecode wb = new WethBytecode();
        weth = IWETH(deployContractFromBytecode(wb.WETH_BYTECODE()));

        // DVT deploy bytecode was modified to mint only to dvt_minter address,
        // so we need to send the tokens to the deployer
        vm.stopPrank();
        vm.startPrank(dvt_minter);
        token.transfer(deployer, token.totalSupply());
        vm.stopPrank();
        vm.startPrank(deployer);

        require(token.balanceOf(deployer) == token.totalSupply());

        uniswapFactory = new UniswapV2Factory(deployer);

        uniswapRouter = IUniswapV2Router02(new UniswapV2Router02(address(uniswapFactory), address(weth)));
        uniswapExchange = IUniswapV2Pair(uniswapFactory.createPair(address(token), address(weth)));

        token.approve(address(uniswapRouter), UNISWAP_INITIAL_TOKEN_RESERVE);

        uniswapRouter.addLiquidityETH{ value: UNISWAP_INITIAL_WETH_RESERVE }(
            address(token), UNISWAP_INITIAL_TOKEN_RESERVE, 1, 1, deployer, 2 * block.timestamp
        );

        lendingPool = new PuppetV2Pool(address(weth), address(token), address(uniswapExchange), address(uniswapFactory));

        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);

        require(lendingPool.calculateDepositOfWETHRequired(1e18) == 3e17);
        require(lendingPool.calculateDepositOfWETHRequired(POOL_INITIAL_TOKEN_BALANCE) == 300000 * 1e18);

        vm.stopPrank();
    }

    function test_PuppetV2() public {
        vm.startPrank(player, player);

        PuppetMasterV2 pm2 = new PuppetMasterV2{ value: player.balance }(
            address(lendingPool), address(uniswapRouter), address(token), address(weth), address(uniswapFactory), player
        );
        token.transfer(address(pm2), token.balanceOf(player));

        pm2.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        require(
            token.balanceOf(address(lendingPool)) == 0,
            "Sorry, you did not solve the challenge! The Puppet lending pool should not have any DVT tokens"
        );
        require(
            token.balanceOf(player) >= POOL_INITIAL_TOKEN_BALANCE,
            "Sorry, you did not solve the challenge! The player does not have all of the pool's tokens"
        );

        console.logString("Congratulations, you solved the challenge! You are the puppet (v2) master!!!");
    }

    function test_Puppet_V2() public {
        return test_PuppetV2();
    }

    function test_Puppetv2() public {
        return test_PuppetV2();
    }

    function test_Puppet_v2() public {
        return test_PuppetV2();
    }

    function test_Puppet2() public {
        return test_PuppetV2();
    }

    function test_Puppet_2() public {
        return test_PuppetV2();
    }

    function test_09() public {
        return test_PuppetV2();
    }
}
