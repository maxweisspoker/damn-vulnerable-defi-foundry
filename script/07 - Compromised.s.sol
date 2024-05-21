// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { IExchange } from "../src/07 - Compromised/Interfaces/IExchange.i.sol";
import { ITrustfulOracle } from "../src/07 - Compromised/Interfaces/ITrustfulOracle.i.sol";
import { ITrustfulOracleInitializer } from "../src/07 - Compromised/Interfaces/ITrustfulOracleInitializer.i.sol";
import { DamnValuableNFT } from "../src/DamnValuableNFT.sol";

///////////////////////////////////////////////////////////////////////////////
import { TheOraclesProphecy } from "../src/07 - Compromised/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////////////////

// Test your solution on a pre-deployed set of "Compromised" contracts
contract CompromisedScript is Script {
    IExchange private exchange;
    ITrustfulOracle private oracle;
    ITrustfulOracleInitializer private oracleInitializer;
    DamnValuableNFT private nftToken;

    address private constant exchange_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant oracle_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant oracleInitializer_address = 0x0000000000000000000000000000000000000000; // change me!!!
    address private constant nftToken_address = 0x0000000000000000000000000000000000000000; // change me!!!

    address[] private TRUSTED_SOURCES = [
        0xA73209FB1a42495120166736362A1DfA9F95A105,
        0xe92401A4d3af5E446d93D11EEc806b1462b39D15,
        0x81A5D6E50C214044bE44cA0CB057fe119097850c
    ];

    function setUp() public {
        exchange = IExchange(payable(exchange_address));
        oracle = ITrustfulOracle(payable(oracle_address));
        oracleInitializer = ITrustfulOracleInitializer(payable(oracleInitializer_address));
        nftToken = DamnValuableNFT(payable(nftToken_address));
    }

    function run() public {
        vm.startBroadcast();

        // Your code goes here

        vm.stopBroadcast();
    }
}
