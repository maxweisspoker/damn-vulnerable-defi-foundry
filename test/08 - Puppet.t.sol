// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { PuppetPool } from "../src/08 - Puppet/PuppetPool.sol";
import { IPuppetPool } from "../src/08 - Puppet/Interfaces/IPuppetPool.i.sol";
import { IUniswapV1Exchange } from "../src/helpers/uniswap-v1-abi/IUniswapV1Exchange.i.sol";
import { IUniswapV1Factory } from "../src/helpers/uniswap-v1-abi/IUniswapV1Factory.i.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";
import { UniswapV1Bytecode } from "../src/helpers/uniswap-v1-abi/UniswapV1Bytecode.sol";

////////////////////////////////////////////////////////////////////
import { PuppetMaster } from "../src/08 - Puppet/YOUR_SOLUTION.sol";
////////////////////////////////////////////////////////////////////

contract PuppetTest is Test {
    DamnValuableToken private token;
    IUniswapV1Factory private uniswapFactory;
    IUniswapV1Exchange private uniswapExchange;
    PuppetPool private lendingPool;
    address private exchangeTemplate;

    // https://github.com/Uniswap/v1-contracts/tree/master/bytecode
    bytes public UNISWAPV1_EXCHANGE_BYTECODE;
    bytes public UNISWAPV1_FACTORY_BYTECODE;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Puppet deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Puppet player")))));

    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 10 * 1e18;
    uint256 private constant UNISWAP_INITIAL_ETH_RESERVE = 10 * 1e18;
    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 1000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 25 * 1e18;
    uint256 private constant POOL_INITIAL_TOKEN_BALANCE = 100000 * 1e18;

    // Calculates how much ETH (in wei) Uniswap will pay for the given amount of tokens
    function calculateTokenToEthInputPrice(uint256 tokensSold, uint256 tokensInReserve, uint256 etherInReserve)
        public
        pure
        returns (uint256)
    {
        return (tokensSold * 997 * etherInReserve) / ((tokensInReserve * 1000) + (tokensSold * 997));
    }

    function deployContractFromBytecode(bytes memory bytecode) public returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0));
    }

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/puppet/puppet.challenge.js
    function setUp() public {
        vm.deal(deployer, UNISWAP_INITIAL_ETH_RESERVE);
        vm.startPrank(deployer);

        // Helper contract that just stores the Uniswap bytecode
        UniswapV1Bytecode ubc = new UniswapV1Bytecode();

        UNISWAPV1_EXCHANGE_BYTECODE = ubc.UNISWAPV1_EXCHANGE_BYTECODE();
        UNISWAPV1_FACTORY_BYTECODE = ubc.UNISWAPV1_FACTORY_BYTECODE();

        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        require(player.balance == PLAYER_INITIAL_ETH_BALANCE);

        // Deploy token to be traded in Uniswap
        token = new DamnValuableToken();

        // Deploy a exchange that will be used as the factory template
        exchangeTemplate = deployContractFromBytecode(UNISWAPV1_EXCHANGE_BYTECODE);

        // Deploy factory, initializing it with the address of the template exchange
        uniswapFactory = IUniswapV1Factory(deployContractFromBytecode(UNISWAPV1_FACTORY_BYTECODE));
        uniswapFactory.initializeFactory(exchangeTemplate);

        // Create a new exchange for the token, and retrieve the deployed exchange's address
        uniswapExchange = IUniswapV1Exchange(uniswapFactory.createExchange(address(token)));

        // Deploy the lending pool
        lendingPool = new PuppetPool(address(token), address(uniswapExchange));

        // Add initial token and ETH liquidity to the pool
        token.approve(address(uniswapExchange), UNISWAP_INITIAL_TOKEN_RESERVE);
        uniswapExchange.addLiquidity{ value: UNISWAP_INITIAL_ETH_RESERVE, gas: 1e6 }(
            0, UNISWAP_INITIAL_TOKEN_RESERVE, block.timestamp * 2
        );

        // Ensure Uniswap exchange is working as expected
        require(
            uniswapExchange.getTokenToEthInputPrice{ gas: 1e6 }(10 * 1e18)
                == calculateTokenToEthInputPrice(10 * 1e18, UNISWAP_INITIAL_TOKEN_RESERVE, UNISWAP_INITIAL_ETH_RESERVE)
        );

        // Setup initial token balances of pool and player accounts
        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);

        // Ensure correct setup of pool. For example, to borrow 1 need to deposit 2
        require(lendingPool.calculateDepositRequired(10 ether) == 20 ether);
        require(lendingPool.calculateDepositRequired(POOL_INITIAL_TOKEN_BALANCE) == (2 * POOL_INITIAL_TOKEN_BALANCE));

        vm.stopPrank();
    }

    function test_Puppet() public {
        vm.startPrank(player, player);

        PuppetMaster pm = new PuppetMaster{ value: player.balance }(
            address(lendingPool), address(uniswapExchange), address(token), player
        );
        token.transfer(address(pm), token.balanceOf(player));

        pm.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        // We ignore the original challenge's requirement for only doing one
        // transaction, because of how this Foundry version is setup. If you
        // are able to solve the challenge within the solveChallenge() function,
        // you have already solved it with a single transaction.

        // Player has taken all tokens from the pool
        require(
            token.balanceOf(address(lendingPool)) == 0,
            "Sorry, you did not solve the challenge! Pool should not have any tokens"
        );

        require(
            token.balanceOf(player) >= POOL_INITIAL_TOKEN_BALANCE,
            "Sorry, you did not solve the challenge! Not enough token balance in player account"
        );

        console.log("Congratulations, you solved the challenge! You are the puppet master!!!");
    }

    function test_PuppetV1() public {
        return test_Puppet();
    }

    function test_Puppet_V1() public {
        return test_Puppet();
    }

    function test_Puppetv1() public {
        return test_Puppet();
    }

    function test_Puppet_v1() public {
        return test_Puppet();
    }

    function test_08() public {
        return test_Puppet();
    }
}
