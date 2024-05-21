// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { IPuppetPool } from "./Interfaces/IPuppetPool.i.sol";
import { IUniswapV1Exchange } from "../helpers/uniswap-v1-abi/IUniswapV1Exchange.i.sol";
import { DamnValuableToken } from "../DamnValuableToken.sol";

contract PuppetMaster {
    IPuppetPool private lendingPool;
    IUniswapV1Exchange private exchange;
    DamnValuableToken private token;
    address private player;

    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 10 * 1e18;
    uint256 private constant UNISWAP_INITIAL_ETH_RESERVE = 10 * 1e18;
    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 1000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 25 * 1e18;
    uint256 private constant POOL_INITIAL_TOKEN_BALANCE = 100000 * 1e18;

    constructor(address _lendingPool, address _exchange, address _token, address _player) payable {
        lendingPool = IPuppetPool(_lendingPool);
        exchange = IUniswapV1Exchange(_exchange);
        token = DamnValuableToken(_token);
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // Once again, the player starts with 25 ETH and 1000 DVTs, which have
        // been transferred into this contract for you to use. And once again,
        // the test checks if the player account has the required eth and tokens,
        // so you must transfer to the player address in order to pass.

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
