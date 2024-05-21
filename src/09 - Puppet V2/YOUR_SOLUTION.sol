// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import { IERC20 } from "./Interfaces/IERC20.i.sol";
import { IWETH } from "./Interfaces/IWETH.i.sol";
import { IPuppetV2Pool } from "./Interfaces/IPuppetV2Pool.i.sol";
import { IUniswapV2Router02 } from "../helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Router02.i.sol";
import { UniswapV2Library } from "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

contract PuppetMasterV2 {
    address private player;
    address private uniswapFactory;
    IERC20 private token;
    IWETH private weth;
    IPuppetV2Pool private lendingPool;
    IUniswapV2Router02 private uniswapRouter;

    uint256 private constant UNISWAP_INITIAL_TOKEN_RESERVE = 100 * 1e18;
    uint256 private constant UNISWAP_INITIAL_WETH_RESERVE = 10 * 1e18;
    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 10000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 20 * 1e18;
    uint256 private constant POOL_INITIAL_TOKEN_BALANCE = 1000000 * 1e18;

    constructor(
        address _lendingPool,
        address _uniswapRouter,
        address _token,
        address _weth,
        address _factory,
        address _player
    ) public payable {
        lendingPool = IPuppetV2Pool(_lendingPool);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        token = IERC20(_token);
        weth = IWETH(_weth);
        uniswapFactory = _factory;
        player = _player;
    }

    function solveChallenge() public {
        // The solidity version being 0.6.6 is simply to enable compilation with
        // the provided PuppetV2Pool. You do not necessarily need to take
        // advantage of any compiler differences between solidity v0.6 and v0.8.

        // It may be helpful to read how to trade tokens on Uniswap v2 using
        // the Uniswap Router contract. (Researching decentralized exchanges
        // and the Constant Product formula as well will help you understand
        // how pricing on Uniswap v2 works, if you're interested. It is not
        // at all necessary for this challenge.)

        // Informational, not necessary!
        // https://www.youtube.com/watch?v=wJGabFwttWI
        // https://www.youtube.com/watch?v=IL7cRj5vzEU

        // And as before, any tokens and ether given to the player have been
        // trasnfered into this contract. You must transfer all the tokens
        // and ether back to the player by the end of your solution in order
        // to pass the challenge.

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. Feel free to alter them or to remove them if you don't use
    // them.
    receive() external payable { }
    fallback() external payable { }
}
