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

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
