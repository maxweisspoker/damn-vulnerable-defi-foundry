// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { Exchange } from "../src/07 - Compromised/Exchange.sol";
import { TrustfulOracle } from "../src/07 - Compromised/TrustfulOracle.sol";
import { TrustfulOracleInitializer } from "../src/07 - Compromised/TrustfulOracleInitializer.sol";
import { DamnValuableNFT } from "../src/DamnValuableNFT.sol";
import { EthPrivToAddr } from "../src/helpers/EthPrivToAddr.sol";
import { StringOperations } from "../src/helpers/StringOperations.sol";

///////////////////////////////////////////////////////////////////////////////
import { TheOraclesProphecy } from "../src/07 - Compromised/YOUR_SOLUTION.sol";
///////////////////////////////////////////////////////////////////////////////

contract CompromisedTest is Test {
    Exchange private exchange;
    TrustfulOracle private oracle;
    TrustfulOracleInitializer private oracleInitializer;
    DamnValuableNFT private nftToken;
    EthPrivToAddr private ethPrivToAddr;
    StringOperations private strings;
    EOARunner private eoarunner;
    string[] private symbols;
    uint256[] private initialPrices;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Compromised deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Compromised player")))));

    address[] private sources = [
        0xA73209FB1a42495120166736362A1DfA9F95A105,
        0xe92401A4d3af5E446d93D11EEc806b1462b39D15,
        0x81A5D6E50C214044bE44cA0CB057fe119097850c
    ];

    uint256 private constant EXCHANGE_INITIAL_ETH_BALANCE = 999 ether;
    uint256 private constant INITIAL_NFT_PRICE = 999 ether;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 0.1 ether;
    uint256 private constant TRUSTED_SOURCE_INITIAL_ETH_BALANCE = 2 ether;

    // Re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/compromised/compromised.challenge.js
    function setUp() public {
        eoarunner = new EOARunner();
        eoarunner.setUp();
        for (uint256 i; i < 3; ++i) {
            symbols.push("DVNFT");
            initialPrices.push(INITIAL_NFT_PRICE);
        }

        vm.startPrank(deployer);

        // Initialize balance of the trusted source addresses
        for (uint256 i; i < 3; ++i) {
            vm.deal(sources[i], TRUSTED_SOURCE_INITIAL_ETH_BALANCE);
            require(sources[i].balance == TRUSTED_SOURCE_INITIAL_ETH_BALANCE);
        }

        // Player starts with limited balance
        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        require(player.balance == PLAYER_INITIAL_ETH_BALANCE);

        // Deploy the oracle and setup the trusted sources with initial prices
        oracleInitializer = new TrustfulOracleInitializer(sources, symbols, initialPrices);
        oracle = TrustfulOracle(address(oracleInitializer.oracle()));

        // Deploy the exchange and get an instance to the associated ERC721 token
        exchange = new Exchange(address(oracle));
        vm.deal(address(exchange), EXCHANGE_INITIAL_ETH_BALANCE);
        nftToken = DamnValuableNFT(address(exchange.token()));
        require(nftToken.owner() == address(0)); // ownership renounced
        require(nftToken.rolesOf(address(exchange)) == nftToken.MINTER_ROLE());

        vm.stopPrank();
    }

    function test_Compromised() public {
        vm.startPrank(player, player);

        TheOraclesProphecy prophet = new TheOraclesProphecy{ value: player.balance }(
            address(exchange), address(oracleInitializer), address(eoarunner), player
        );
        prophet.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        require(
            address(exchange).balance == 0, "Sorry, you did not solve the challenge! Exchange must have lost all ETH"
        );

        require(
            player.balance > EXCHANGE_INITIAL_ETH_BALANCE,
            "Sorry, you did not solve the challenge! Player's ETH balance must have significantly increased"
        );

        require(nftToken.balanceOf(player) == 0, "Sorry, you did not solve the challenge! Player must not own any NFT");

        require(
            oracle.getMedianPrice("DVNFT") == INITIAL_NFT_PRICE,
            "Sorry, you did not solve the challenge! NFT price shouldn't have changed"
        );

        console.log("Congratulations, you solved the challenge! You fulfilled the Oracle's prophecy!!!");
    }

    function test_compromised() public {
        return test_Compromised();
    }

    function test_07() public {
        return test_Compromised();
    }
}

contract EOARunner is Test {
    EthPrivToAddr private ethPrivToAddr;
    StringOperations private strings;
    uint256 private callNum;

    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Compromised player")))));

    function setUp() public {
        ethPrivToAddr = new EthPrivToAddr();
        strings = new StringOperations();
        callNum = 1;
    }

    function RunAsEOA(string calldata privKey, address target, bytes calldata data) public payable returns (bool) {
        if (target == msg.sender) return false;

        if (bytes(privKey).length == 0 || bytes(privKey).length % 2 != 0) return false;

        (bool success, bytes memory pkb) = address(strings).call(abi.encodeWithSignature("hextoBytes(string)", privKey));
        if (!success) return false;
        if (pkb.length != 96) return false;

        bytes32 pk = bytes32(abi.decode(pkb, (bytes)));

        if (
            uint256(pk) < 2
                || uint256(pk) > 115792089237316195423570985008687907852837564279074904382605163141518161494336
        ) {
            return false;
        }

        // Should never fail, in theory...
        address eoa = ethPrivToAddr.getAddress(pk);

        console.log("");
        console.log("--------");
        console.log("RunAsEOA private key:          ", string.concat("0x", strings.iToHex(abi.encode(pk))));
        console.log("RunAsEOA derived EOA address:  ", eoa);
        console.log("RunAsEOA target address:       ", target);

        // If calldata is empty, don't display it
        if (
            keccak256(bytes(strings.iToHex(abi.encode(data))))
                == bytes32(0x0fa2908515096355fb647135a5b1e592da565155c961aae7e69cb3bdef2d45bf)
        ) {
            // Empty call data would technically be
            // 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000
            // But I don't want players to get confused by this console.log entry.
            console.log("RunAsEOA target calldata:      ", "0x");
        } else {
            console.log("RunAsEOA target calldata:      ", string.concat("0x", strings.iToHex(abi.encode(data))));
        }

        console.log("RunAsEOA value (wei) sent:     ", msg.value);
        console.log("");

        // Give eoa the msg.value, which is still removed from the msg.sender
        // because it gets trapped in this contract. So the math works out...
        vm.deal(eoa, msg.value);

        // I'm not 100% clear on how the pranks work, so I'm declaring this beforehand
        bool success2;

        // RunAsEOA should only ever be called during a prank as player, so we
        // stop the prank and set it back afterwards.
        vm.stopPrank();
        vm.startPrank(eoa, eoa);

        (success2,) = target.call{ value: msg.value }(data);

        vm.stopPrank();
        vm.startPrank(player);

        string memory s = strings.toString(callNum);
        if (success2) {
            console.log(
                string.concat(
                    "RunAsEOA call ", strings.substring(s, bytes(s).length - 2, bytes(s).length), ":              "
                ),
                "Success!"
            );
        } else {
            console.log(
                string.concat(
                    "RunAsEOA call ", strings.substring(s, bytes(s).length - 2, bytes(s).length), ":              "
                ),
                "Failed"
            );
        }
        callNum++;
        console.log("--------");
        console.log("");

        return success2;
    }
}
