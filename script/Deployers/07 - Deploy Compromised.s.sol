// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { Exchange } from "../../src/07 - Compromised/Exchange.sol";
import { TrustfulOracle } from "../../src/07 - Compromised/TrustfulOracle.sol";
import { TrustfulOracleInitializer } from "../../src/07 - Compromised/TrustfulOracleInitializer.sol";
import { DamnValuableNFT } from "../../src/DamnValuableNFT.sol";

// Deploy the challenge in order to practice
contract DeployCompromisedScript is Script {
    string[] private symbols;
    uint256[] private initialPrices;

    // Broadcast account need 1005 ether + gas to successfully complete transaction
    uint256 private constant EXCHANGE_INITIAL_ETH_BALANCE = 999 ether;
    uint256 private constant TRUSTED_SOURCE_INITIAL_ETH_BALANCE = 2 ether;

    uint256 private constant INITIAL_NFT_PRICE = 999 ether;

    // If these are changed, make sure the private key is accessible so your funds are not lost
    address[] private sources = [
        0xA73209FB1a42495120166736362A1DfA9F95A105,
        0xe92401A4d3af5E446d93D11EEc806b1462b39D15,
        0x81A5D6E50C214044bE44cA0CB057fe119097850c
    ];

    function setUp() public {
        for (uint256 i; i < 3; ++i) {
            symbols.push("DVNFT");
            initialPrices.push(INITIAL_NFT_PRICE);
        }
    }

    function run() public {
        // You may need to set your private key in vm.startBroadcast(), or use
        // the --private-key and --sender options when running forge script.
        // This deployment requires funding the contracts to set their initial
        // balance.
        vm.startBroadcast();

        for (uint256 i; i < 3; ++i) {
            (bool s,) = payable(sources[i]).call{ value: TRUSTED_SOURCE_INITIAL_ETH_BALANCE }("");
            require(s, "Not enough Eth to fund oracle source.");
            require(sources[i].balance == TRUSTED_SOURCE_INITIAL_ETH_BALANCE, "Not enough Eth to fund oracle source.");
        }

        TrustfulOracleInitializer oracleInitializer = new TrustfulOracleInitializer(sources, symbols, initialPrices);
        TrustfulOracle oracle = TrustfulOracle(address(oracleInitializer.oracle()));

        Exchange exchange = new Exchange(address(oracle));
        (bool success,) = payable(address(exchange)).call{ value: EXCHANGE_INITIAL_ETH_BALANCE }("");
        require(success, "Not enough Eth to fund exchange.");
        require(address(exchange).balance == EXCHANGE_INITIAL_ETH_BALANCE, "Not enough Eth to fund exchange.");

        DamnValuableNFT nftToken = DamnValuableNFT(address(exchange.token()));

        vm.stopBroadcast();

        require(nftToken.owner() == address(0));
        require(nftToken.rolesOf(address(exchange)) == nftToken.MINTER_ROLE());

        console.log("Oracle sources addresses:           ", address(sources[0]));
        console.log("                                    ", address(sources[1]));
        console.log("                                    ", address(sources[2]));
        console.log("TrustfulOracleInitializer address:  ", address(oracleInitializer));
        console.log("TrustfulOracle address:             ", address(oracle));
        console.log("Exchange address:                   ", address(exchange));
        console.log("DamnValuableNFT address:            ", address(nftToken));
    }
}
