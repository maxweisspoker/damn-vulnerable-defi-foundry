// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

// The player may not have access to the original contracts, so the
// player should use these or other interfaces.
import { IExchange } from "./Interfaces/IExchange.i.sol";
import { ITrustfulOracle } from "./Interfaces/ITrustfulOracle.i.sol";
import { ITrustfulOracleInitializer } from "./Interfaces/ITrustfulOracleInitializer.i.sol";

import { IEOARunner } from "./Interfaces/IEOARunner.i.sol";
import { DamnValuableNFT } from "../DamnValuableNFT.sol";

contract TheOraclesProphecy {
    address private player;
    IEOARunner private eoaCaller;
    IExchange private exchange;
    ITrustfulOracle private oracle;
    ITrustfulOracleInitializer private oracleInitializer;
    DamnValuableNFT private nftToken;

    address[] private TRUSTED_SOURCES = [
        0xA73209FB1a42495120166736362A1DfA9F95A105,
        0xe92401A4d3af5E446d93D11EEc806b1462b39D15,
        0x81A5D6E50C214044bE44cA0CB057fe119097850c
    ];

    uint256 private constant EXCHANGE_INITIAL_ETH_BALANCE = 999 ether;
    uint256 private constant INITIAL_NFT_PRICE = 999 ether;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 private constant TRUSTED_SOURCE_INITIAL_ETH_BALANCE = 2 ether;

    constructor(address _exchange, address _oracleInitializer, address _eoa, address _player) payable {
        player = _player;
        eoaCaller = IEOARunner(payable(_eoa));
        exchange = IExchange(payable(_exchange));
        oracle = ITrustfulOracle(payable(address(exchange.oracle())));
        oracleInitializer = ITrustfulOracleInitializer(payable(address(_oracleInitializer)));
        nftToken = DamnValuableNFT(payable(address(exchange.token())));
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // As before, while the challenge text says the player starts with
        // 0.1 eth, we have put that 0.1 eth into this contract for you to
        // use instead.

        // You may need to send a transaction as an EOA account. While normally
        // this would not be possible inside a contract, we have taken advantage
        // of Foundry's "cheat codes" to implement a function you can use inside
        // here to send that transaction. If you look in the IEOARunner interface
        // file, you will find the function "RunAsEOA()" and a description for
        // how to use it.

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
