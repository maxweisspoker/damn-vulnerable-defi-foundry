// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { PuppetPool } from "../../src/08 - Puppet/PuppetPool.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { UniswapV1Bytecode } from "../../src/helpers/uniswap-v1-abi/UniswapV1Bytecode.sol";
import { IUniswapV1Exchange } from "../../src/helpers/uniswap-v1-abi/IUniswapV1Exchange.i.sol";
import { IUniswapV1Factory } from "../../src/helpers/uniswap-v1-abi/IUniswapV1Factory.i.sol";

// Deploy the challenge in order to practice
contract DeployPuppetScript is Script {
    // The broadcast address needs 10 ether plus about 1.5 million gas to
    // broadcast this. Additionally, note that the starting DVT tokens for the
    // player get transferred to the broadcast msg.sender.

    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 10 * 1e18;
    uint256 private constant UNISWAP_INITIAL_ETH_RESERVE = 10 ether;
    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 1000 * 1e18;
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

    function setUp() public { }

    function run() public {
        // You may need to set your private key in vm.startBroadcast(), or use
        // the --private-key and --sender options when running forge script.
        // This deployment requires funding the contracts to set their initial
        // balance.
        vm.startBroadcast();

        // Helper contract that just stores the Uniswap bytecode
        UniswapV1Bytecode ubc = new UniswapV1Bytecode();

        // Deploy a exchange that will be used as the factory template
        address exchangeTemplate = deployContractFromBytecode(ubc.UNISWAPV1_EXCHANGE_BYTECODE());

        // Deploy factory, initializing it with the address of the template exchange
        IUniswapV1Factory uniswapFactory =
            IUniswapV1Factory(payable(deployContractFromBytecode(ubc.UNISWAPV1_FACTORY_BYTECODE())));
        uniswapFactory.initializeFactory(exchangeTemplate);

        // Deploy token to be traded in Uniswap
        DamnValuableToken token = new DamnValuableToken();

        // Create a new exchange for the token, and retrieve the deployed exchange's address
        IUniswapV1Exchange uniswapExchange = IUniswapV1Exchange(payable(uniswapFactory.createExchange(address(token))));

        // Deploy the lending pool
        PuppetPool lendingPool = new PuppetPool(address(token), address(uniswapExchange));

        // Add initial token and ETH liquidity to the pool
        token.approve(address(uniswapExchange), UNISWAP_INITIAL_TOKEN_RESERVE);

        // Be explicit with values and double-check transfer to avoid getting MEV'd
        // in the event that you are for god-knows-what reason deploying this on
        // a real chain
        uniswapExchange.addLiquidity{ value: UNISWAP_INITIAL_ETH_RESERVE, gas: 1e6 }(
            UNISWAP_INITIAL_ETH_RESERVE, UNISWAP_INITIAL_TOKEN_RESERVE, block.timestamp + 1200
        );
        require(address(uniswapExchange).balance == UNISWAP_INITIAL_ETH_RESERVE, "MEV");

        // Setup initial token balances of pool and player accounts
        token.transfer(address(lendingPool), POOL_INITIAL_TOKEN_BALANCE);
        //token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE); // must set player address

        vm.stopBroadcast();

        // Ensure Uniswap exchange is working as expected
        require(
            uniswapExchange.getTokenToEthInputPrice{ gas: 1e6 }(10 * 1e18)
                == calculateTokenToEthInputPrice(10 * 1e18, UNISWAP_INITIAL_TOKEN_RESERVE, UNISWAP_INITIAL_ETH_RESERVE)
        );

        // Ensure correct setup of pool. For example, to borrow 1 need to deposit 2
        require(lendingPool.calculateDepositRequired(10 ether) == 20 ether);
        require(lendingPool.calculateDepositRequired(POOL_INITIAL_TOKEN_BALANCE) == (2 * POOL_INITIAL_TOKEN_BALANCE));

        console.log("Uniswap V1 Factory address:            ", address(uniswapFactory));
        console.log("Uniswap V1 Exchange template address:  ", address(exchangeTemplate));
        console.log("Uniswap V1 Exchange address:           ", address(uniswapExchange));
        console.log("DamnValuableToken address:             ", address(token));
        console.log("PuppetPool address:                    ", address(lendingPool));
    }
}
