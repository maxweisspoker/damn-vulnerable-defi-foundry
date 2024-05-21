// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { ClimberVault } from "../../src/12 - Climber/ClimberVault.sol";
import { IClimberVault } from "../../src/12 - Climber/Interfaces/IClimberVault.i.sol";
import { IClimberTimelock } from "../../src/12 - Climber/Interfaces/IClimberTimelock.i.sol";
import "../../src/12 - Climber/ClimberConstants.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Deploy the challenge in order to practice
contract DeployClimberScript is Script {
    uint256 private constant VAULT_TOKEN_BALANCE = 10000000 * 1e18;
    uint64 private constant TIMELOCK_DELAY = 60 * 60;

    // Arbitrary addresses we don't need the private keys for
    address private constant sweeper = address(uint160(bytes20(keccak256(abi.encode("Climber sweeper")))));
    address private constant proposer = address(uint160(bytes20(keccak256(abi.encode("Climber proposer")))));

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        // Deploy the vault behind a proxy using the UUPS pattern,
        // passing the necessary addresses for the `ClimberVault::initialize(address,address,address)` function
        IClimberVault vault = IClimberVault(
            address(
                new ERC1967Proxy(
                    address(new ClimberVault()),
                    abi.encodeWithSignature("initialize(address,address,address)", address(this), proposer, sweeper)
                )
            )
        );

        // Deploy token and transfer initial token balance to the vault
        DamnValuableToken token = new DamnValuableToken();
        token.transfer(address(vault), VAULT_TOKEN_BALANCE);

        vm.stopBroadcast();

        IClimberTimelock timelock = IClimberTimelock(payable(address(vault.owner())));

        require(vault.getSweeper() == sweeper);
        require(vault.getLastWithdrawalTimestamp() > 0);
        require(vault.owner() != address(0));
        require(vault.owner() != address(this));

        // Ensure timelock delay is correct and cannot be changed
        require(timelock.delay() == TIMELOCK_DELAY);

        vm.expectRevert(abi.encodeWithSignature("CallerNotTimelock()"));
        timelock.updateDelay(TIMELOCK_DELAY + 1);

        // Ensure timelock roles are correctly initialized
        require(timelock.hasRole(PROPOSER_ROLE, proposer));
        require(timelock.hasRole(ADMIN_ROLE, address(timelock)));

        console.log("Climber Vault address:     ", address(vault));
        console.log("Climber Timelock address:  ", address(vault.owner()));
        console.log("DVT Token address:         ", address(token));
        console.log("Sweeper address:           ", address(sweeper));
        console.log("Proposer address:          ", address(proposer));
    }
}
