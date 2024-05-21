// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { TrusterLenderPool } from "../../src/03 - Truster/TrusterLenderPool.sol";
import { DamnValuableToken } from "../../src/DamnValuableToken.sol";

// Deploy the challenge in order to practice
contract DeployTrusterScript is Script {
    uint256 private constant TOKENS_IN_POOL = 1000000 * 1e18;

    function setUp() public { }

    function run() public {
        vm.startBroadcast();

        DamnValuableToken token = new DamnValuableToken();
        TrusterLenderPool pool = new TrusterLenderPool(token);
        token.transfer(address(pool), TOKENS_IN_POOL);

        vm.stopBroadcast();

        require(address(pool.token()) == address(token));
        require(token.balanceOf(address(pool)) == TOKENS_IN_POOL);
        require(address(pool) != address(0));
        require(address(token) != address(0));
        console.log("TrusterLenderPool address: ", address(pool));
        console.log("DVT token  address:        ", address(token));
    }
}
