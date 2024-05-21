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

        // Your code here
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable { }
    fallback() external payable { }
}
