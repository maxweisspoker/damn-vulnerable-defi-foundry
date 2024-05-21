// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { ERC1967Proxy } from
    "openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";
import { AuthorizerUpgradeable } from "../src/13 - Wallet Mining/AuthorizerUpgradeable.sol";
import { IAuthorizerUpgradeable } from "../src/13 - Wallet Mining/Interfaces/IAuthorizerUpgradeable.i.sol";
import { WalletDeployer } from "../src/13 - Wallet Mining/WalletDeployer.sol";
import { CreateAddressNonce } from "../src/helpers/CreateAddressNonce.sol";
import { StringOperations } from "../src/helpers/StringOperations.sol";

/////////////////////////////////////////////////////////////////////////
import { GoldStrike } from "../src/13 - Wallet Mining/YOUR_SOLUTION.sol";
/////////////////////////////////////////////////////////////////////////

contract WalletMiningTest is Test {
    address[] private wards;
    address[] private aims;
    uint256 private initialWalletDeployerTokenBalance;
    IAuthorizerUpgradeable private authorizer;
    DamnValuableToken private token;
    WalletDeployer private walletDeployer;

    address private constant DEPOSIT_ADDRESS = 0x9B6fb606A9f5789444c17768c6dFCF2f83563801;
    uint256 private constant DEPOSIT_TOKEN_AMOUNT = 20000000 * 1e18;

    address private constant deployer = address(uint160(bytes20(keccak256(abi.encode("Wallet Mining deployer")))));
    address private constant player = address(uint160(bytes20(keccak256(abi.encode("Wallet Mining player")))));

    address private constant ward = address(uint160(bytes20(keccak256(abi.encode("Wallet Mining ward")))));

    function getBytecodeSize(address deployedContract) public view returns (uint256 size) {
        assembly {
            size := extcodesize(deployedContract)
        }
    }

    // Partial re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/wallet-mining/wallet-mining.challenge.js
    function setUp() public {
        // You're not supposed to know this address ahead of time, so I added
        // this modicum of obfuscation in case you just want to read how the
        // test works.
        vm.deal(address(uint160(152164005383444070586927573446451720464574188138)), 1 ether); // gas money

        vm.startPrank(deployer);

        // Deploy Damn Valuable Token contract
        token = new DamnValuableToken();

        wards.push(ward);
        aims.push(DEPOSIT_ADDRESS);

        // Deploy authorizer with the corresponding proxy
        address authorizer_logicContract = address(new AuthorizerUpgradeable());
        authorizer = IAuthorizerUpgradeable(
            address(
                new ERC1967Proxy(
                    authorizer_logicContract, abi.encodeWithSignature("init(address[],address[])", wards, aims)
                )
            )
        );
        require(authorizer.owner() == deployer);
        require(authorizer.can(ward, DEPOSIT_ADDRESS));
        require(!authorizer.can(player, DEPOSIT_ADDRESS));

        // Deploy Safe Deployer contract
        walletDeployer = new WalletDeployer(address(token));
        require(walletDeployer.chief() == deployer);
        require(walletDeployer.gem() == address(token));

        // Set Authorizer in Safe Deployer
        walletDeployer.rule(address(authorizer));
        require(walletDeployer.mom() == address(authorizer));

        // vm.expectRevert() does not work as expected when there are nested calls,
        // nor does the try/catch, nor a low-level call(). In fact, nothing I've
        // tried can catch the revert here. The only way I seem to be able to
        // test if the nested call reverted somewhere is the fact that the
        // can() function returns something (true or false) when it doesn't
        // revert, and returns nothing when it does revert. Therefore, to test
        // for a revert, I simply check if there is any returned data. The
        // easiest way I've found to do that is hashing rather than trying
        // to get bytes() and byte lengths and types to work together. So I
        // check the non-revert by validating that the return data does not
        // match the hash of nothing (0xc5d2...), and check for a revert by
        // validating that the hash does match that value. If you know a better
        // way to do this, please submit a pull request!

        // keccak256(bytes("")) => bytes32(bytes(hex"c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"))

        // First call should not revert, so return value hash should not match 0xc5d2...
        (bool s1, bytes memory data1) =
            address(walletDeployer).call(abi.encodeWithSignature("can(address,address)", ward, DEPOSIT_ADDRESS));
        require(s1); // Ensure we don't get empty data returned because the call itself failed
        require(
            keccak256(data1) != bytes32(bytes(hex"c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"))
        );

        // Second call should revert, so return value hash should match 0xc5d2...
        (bool s2, bytes memory data2) =
            address(walletDeployer).call(abi.encodeWithSignature("can(address,address)", player, DEPOSIT_ADDRESS));
        require(s2); // Ensure we don't get empty data returned because the call itself failed
        require(
            keccak256(data2) == bytes32(bytes(hex"c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"))
        );

        // Fund Safe Deployer with tokens
        initialWalletDeployerTokenBalance = walletDeployer.pay() * 43;
        token.transfer(address(walletDeployer), initialWalletDeployerTokenBalance);

        // Ensure these accounts start empty
        require(getBytecodeSize(DEPOSIT_ADDRESS) == 0);
        require(getBytecodeSize(address(walletDeployer.fact())) == 0);
        require(getBytecodeSize(walletDeployer.copy()) == 0);

        // Deposit large amount of DVT tokens to the deposit address
        token.transfer(DEPOSIT_ADDRESS, DEPOSIT_TOKEN_AMOUNT);

        // Ensure initial balances are set correctly
        require(token.balanceOf(DEPOSIT_ADDRESS) == DEPOSIT_TOKEN_AMOUNT);
        require(token.balanceOf(address(walletDeployer)) == initialWalletDeployerTokenBalance);
        require(token.balanceOf(player) == 0);

        vm.stopPrank();
    }

    function test_WalletMining() public {
        // All of the helper functions I added to make up for the lack of the
        // ethers.js library
        CreateAddressNonce nonceHelper = new CreateAddressNonce();
        TxReplayer replayer = new TxReplayer();
        replayer.setPlayer(player);
        GetStorageAt storageHelper = new GetStorageAt();

        vm.startPrank(player, player);

        GoldStrike gold = new GoldStrike(
            address(token),
            address(authorizer),
            address(walletDeployer),
            address(nonceHelper),
            address(replayer),
            address(storageHelper),
            player
        );
        gold.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        // Factory account must have code
        require(
            getBytecodeSize(address(walletDeployer.fact())) != 0,
            "Sorry, you did not solve the challenge! Factory account must have code"
        );

        // Master copy account must have code
        require(
            getBytecodeSize(walletDeployer.copy()) != 0,
            "Sorry, you did not solve the challenge! Master copy account must have code"
        );

        // Deposit account must have code
        require(
            getBytecodeSize(DEPOSIT_ADDRESS) != 0,
            "Sorry, you did not solve the challenge! Deposit account must have code"
        );

        // The deposit address and the Safe Deployer contract must not hold tokens
        require(
            token.balanceOf(DEPOSIT_ADDRESS) == 0,
            "Sorry, you did not solve the challenge! Deposit address must not hold tokens"
        );
        require(
            token.balanceOf(address(walletDeployer)) == 0,
            "Sorry, you did not solve the challenge! Safe Deployer contract must not hold tokens"
        );

        // Player must own all tokens
        require(
            token.balanceOf(player) == initialWalletDeployerTokenBalance + DEPOSIT_TOKEN_AMOUNT,
            "Sorry, you did not solve the challenge! Player must own all tokens"
        );

        console.log("Congratulations, you solved the challenge! You have struck gold!!!");
    }

    function test_Wallet_Mining() public {
        return test_WalletMining();
    }

    function test_wallet_mining() public {
        return test_WalletMining();
    }

    function test_walletmining() public {
        return test_WalletMining();
    }

    function test_13() public {
        return test_WalletMining();
    }
}

// Very fragile, do not use outside of this challenge!
contract TxReplayer is Test {
    address private player;
    StringOperations private strings = new StringOperations();

    function setPlayer(address p) public {
        player = p;
    }

    function setUp() public { }

    function ReplayTransactionFromID(bytes32 txId) public {
        // vm.transact() is still broken, so we have to do this the hard way...

        string memory txIdString = strings.iToHex(strings.bytes32ToBytes(txId));
        bytes memory stdout;
        bytes memory txCallData;

        // You may want to set a custom RPC endpoint here in these external calls

        string[] memory command = new string[](3);
        command[0] = "bash";
        command[1] = "-c";
        command[2] = string.concat("cast tx -j ", txIdString, " | jq -r .from");

        stdout = vm.ffi(command);
        address from = address(bytes20(stdout));
        if (keccak256(stdout) == keccak256(bytes("null"))) {
            from = address(0);
        }

        command[2] = string.concat("cast tx -j ", txIdString, " | jq -r .to");
        stdout = vm.ffi(command);
        address to = address(bytes20(stdout));
        if (keccak256(stdout) == keccak256(bytes("null"))) {
            to = address(0);
        }

        command[2] = string.concat("cast tx -j ", txIdString, " | jq -r .input");
        stdout = vm.ffi(command);
        txCallData = strings.fromHex(strings.iToHex(stdout));

        // can potentiall be wrong if the calldata is the same four bytes, but
        // for the purposes of this test, we can ignore that
        if (keccak256(stdout) == keccak256(bytes("null"))) {
            txCallData = "";
        }

        command[2] = string.concat("cast tx -j ", txIdString, " | jq -r .value | cast to-uint256");
        stdout = vm.ffi(command);
        uint256 value = uint256(bytes32(stdout));

        command[2] = string.concat("cast tx -j ", txIdString, " | jq -r .nonce | cast to-uint256");
        stdout = vm.ffi(command);
        uint64 nonce = uint64(uint256(bytes32(stdout)));

        uint64 currentNonce = vm.getNonce(from);

        require(nonce <= currentNonce, "Cannot replay transaction with a lower nonce than the address currently has");

        if (nonce > currentNonce) {
            vm.setNonce(from, nonce);
        }

        vm.stopPrank();
        vm.startPrank(from, from);

        // obviously, this breaks if create2 is used, but the tx's the player
        // should be trying to replay occured long before create2 existed
        if (to == address(0)) {
            address deployed;
            assembly {
                deployed := create(0, add(txCallData, 0x20), mload(txCallData))
            }
            require(deployed != address(0), "Unknown error attempting to replay a contract creation");
        } else {
            (bool success,) = to.call{ value: value }(txCallData);
            require(success, "Unknown error occured while replaying transaction");
        }

        vm.setNonce(from, nonce + 1);

        vm.stopPrank();
        vm.startPrank(player, player);
    }
}

contract GetStorageAt is Test {
    function GetStorageAtSlot(address addr, bytes32 slot) public returns (bytes32) {
        return vm.load(addr, slot);
    }
}
