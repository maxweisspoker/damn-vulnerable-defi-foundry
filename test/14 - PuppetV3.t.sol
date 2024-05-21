// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import { Test, console } from "forge-std/Test.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { IERC20Minimal } from "@uniswap/v3-core/contracts/interfaces/IERC20Minimal.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { TransferHelper } from "@uniswap/v3-core/contracts/libraries/TransferHelper.sol";
import { OracleLibrary } from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import { UniswapV3FactoryBytecode } from "../src/helpers/uniswap-v3-abi-and-bytecode/UniswapV3FactoryBytecode.sol";
import { IUniswapV3Factory } from "../src/helpers/uniswap-v3-abi-and-bytecode/IUniswapV3Factory.i.sol";
import { UniswapV3PoolBytecode } from "../src/helpers/uniswap-v3-abi-and-bytecode/UniswapV3PoolBytecode.sol";
import { TokenDescriptorBytecode } from "../src/helpers/uniswap-v3-abi-and-bytecode/TokenDescriptorBytecode.sol";
import { TokenDescriptorProxyBytecode } from
    "../src/helpers/uniswap-v3-abi-and-bytecode/TokenDescriptorProxyBytecode.sol";
import { INonfungiblePositionManager } from
    "../src/helpers/uniswap-v3-abi-and-bytecode/INonfungiblePositionManager.i.sol";
import { NonfungiblePositionManagerBytecode } from
    "../src/helpers/uniswap-v3-abi-and-bytecode/NonfungiblePositionManagerBytecode.sol";
import { UniswapV3RouterBytecode } from "../src/helpers/uniswap-v3-abi-and-bytecode/UniswapV3RouterBytecode.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { WethBytecode } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/WethBytecode.sol";
import { IWETH } from "../src/09 - Puppet V2/Interfaces/IWETH.i.sol";
import { DamnValuableTokenBytecode } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/DamnValuableTokenBytecode.sol";
import { IERC20 } from "../src/09 - Puppet V2/Interfaces/IERC20.i.sol";
import { PuppetV3Pool } from "../src/14 - Puppet V3/PuppetV3Pool.sol";
import { Math } from "../src/helpers/uniswap-v2-solc0.6-puppetv2/Math.sol";
import { EthPrivToAddr } from "../src/helpers/EthPrivToAddr.sol";
import { StringOperations } from "../src/helpers/StringOperations.sol";
import { SleepViaVMWarp } from "../src/helpers/Sleeper.sol";

/////////////////////////////////////////////////////////////////////////
import { PuppetMasterV3 } from "../src/14 - Puppet V3/YOUR_SOLUTION.sol";
/////////////////////////////////////////////////////////////////////////

// The setUp function is modified to check if the hard-coded addresses contain
// bytecode already and only deploy the code if the addresses are empty.
// Therefore, this test should be able to be run with or without a mainnet fork.
contract PuppetV3Test is Test {
    address private deployer;
    address private player;
    SleepViaVMWarp private sleeper;
    IUniswapV3Factory private uniswapFactory;
    INonfungiblePositionManager private uniswapPositionManager;
    IWETH private weth;
    IERC20 private token;
    IUniswapV3Pool private uniswapPool;
    ISwapRouter private uniswapRouter;
    PuppetV3Pool private lendingPool;
    uint256 private initialBlockTimestamp;

    // Initial liquidity amounts for Uniswap v3 pool
    uint256 private constant UNISWAP_INITIAL_TOKEN_LIQUIDITY = 100 * 1e18;
    uint256 private constant UNISWAP_INITIAL_WETH_LIQUIDITY = 100 * 1e18;

    uint256 private constant PLAYER_INITIAL_TOKEN_BALANCE = 110 * 1e18;
    uint256 private constant PLAYER_INITIAL_ETH_BALANCE = 1e18;
    uint256 private constant DEPLOYER_INITIAL_ETH_BALANCE = 200 * 1e18;

    uint256 private constant LENDING_POOL_INITIAL_TOKEN_BALANCE = 1000000 * 1e18;

    uint24 private constant FEE = 3000;

    function getBytecodeSize(address deployedContract) public view returns (uint256 size) {
        assembly {
            size := extcodesize(deployedContract)
        }
    }

    // Thanks ChatGPT for creating this function
    function getBytecode(address _addr) public view returns (bytes memory) {
        bytes memory code;
        uint256 codeSize;

        assembly {
            // Retrieve the size of the code
            codeSize := extcodesize(_addr)
        }
        require(codeSize > 0);

        // Allocate memory for the bytecode
        code = new bytes(codeSize);

        assembly {
            // Copy the code
            // The first memory "slot" of the code is the size, which is already
            // set. That's why we start copying at the location code+32.
            extcodecopy(_addr, add(code, 0x20), 0, codeSize)
        }

        return code;
    }

    function deployContractFromBytecode(bytes memory bytecode) public returns (address deployed) {
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0)); // 0 = failure to deploy
    }

    function encodePriceSqrt(uint256 reserve0, uint256 reserve1) public pure returns (uint160) {
        require(reserve0 != 0);
        require(reserve1 != 0);
        return uint160(uint256(Math.sqrt(reserve1 / reserve0) * (2 ** 96)));
    }

    // Partial re-write of:
    // https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/puppet-v3/puppet-v3.challenge.js
    function setUp() public {
        EthPrivToAddr ethPrivToAddr = new EthPrivToAddr();

        // Initialize player account
        // using private key of account #2 in Hardhat's node
        player =
            ethPrivToAddr.getAddress(bytes32(hex"59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"));

        // Initialize deployer account
        // using private key of account #1 in Hardhat's node
        deployer =
            ethPrivToAddr.getAddress(bytes32(hex"ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"));

        vm.deal(player, PLAYER_INITIAL_ETH_BALANCE);
        require(player.balance == PLAYER_INITIAL_ETH_BALANCE);

        vm.deal(deployer, DEPLOYER_INITIAL_ETH_BALANCE);
        require(deployer.balance == DEPLOYER_INITIAL_ETH_BALANCE);

        vm.startPrank(deployer);

        // Create or get a reference to the Uniswap V3 Factory contract
        if (getBytecodeSize(0x1F98431c8aD98523631AE4a59f267346ea31F984) == 0) {
            UniswapV3FactoryBytecode uv3b = new UniswapV3FactoryBytecode();
            // Unknown issues with using create bytecode, so we just use the
            // deployed bytecode from mainnet and then manually modify the
            // storage
            vm.etch(address(0x1F98431c8aD98523631AE4a59f267346ea31F984), uv3b.UNISWAP_V3_FACTORY_BYTECODE_DEPLOYED());
            vm.store( // Set owner
                0x1F98431c8aD98523631AE4a59f267346ea31F984,
                bytes32(uint256(3)),
                bytes32(uint256(uint160(address(deployer))))
            );
            uniswapFactory = IUniswapV3Factory(address(0x1F98431c8aD98523631AE4a59f267346ea31F984));
            uniswapFactory.enableFeeAmount(500, 10);
            uniswapFactory.enableFeeAmount(3000, 60);
            uniswapFactory.enableFeeAmount(10000, 200);
        } else {
            uniswapFactory = IUniswapV3Factory(address(0x1F98431c8aD98523631AE4a59f267346ea31F984));
            vm.store( // Set owner
                0x1F98431c8aD98523631AE4a59f267346ea31F984,
                bytes32(uint256(3)),
                bytes32(uint256(uint160(address(deployer))))
            );
        }
        require(uniswapFactory.owner() == address(deployer));

        // Create or get a reference to WETH9
        if (getBytecodeSize(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2) == 0) {
            WethBytecode wb = new WethBytecode();
            address wethAddr = deployContractFromBytecode(wb.WETH_BYTECODE());
            vm.etch(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), getBytecode(wethAddr));
        }
        weth = IWETH(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));

        // Deployer wraps ETH in WETH
        uint256 currBalance = deployer.balance;
        vm.deal(deployer, UNISWAP_INITIAL_WETH_LIQUIDITY);
        weth.deposit{ value: UNISWAP_INITIAL_WETH_LIQUIDITY }();
        require(weth.balanceOf(deployer) == UNISWAP_INITIAL_WETH_LIQUIDITY);
        vm.deal(deployer, currBalance);

        // Deploy DVT token. This is the token to be traded against WETH in the Uniswap v3 pool.
        DamnValuableTokenBytecode dvtbc = new DamnValuableTokenBytecode();
        token = IERC20(deployContractFromBytecode(dvtbc.DAMN_VALUABLE_BYTECODE()));
        // DVT deploy bytecode was modified to mint only to a specific address,
        // so we need to send the tokens to the deployer
        vm.stopPrank();
        vm.startPrank(address(uint160(bytes20(keccak256(abi.encode("Damn Valuable Token Owner"))))));
        token.transfer(deployer, token.totalSupply());
        vm.stopPrank();
        vm.startPrank(deployer);

        // Just for consistency with forking
        if (address(token) != 0x8CeA85eC7f3D314c4d144e34F2206C8Ac0bbadA1) {
            vm.etch(address(0x8CeA85eC7f3D314c4d144e34F2206C8Ac0bbadA1), getBytecode(address(token)));
            token = IERC20(address(0x8CeA85eC7f3D314c4d144e34F2206C8Ac0bbadA1));
            deal(0x8CeA85eC7f3D314c4d144e34F2206C8Ac0bbadA1, deployer, type(uint256).max);
        }

        // Token descriptor is necessary to deploy the position manager.
        // We don't need to save it, but the address is embedded in the
        // position manager deployment code constructor arguments, so it needs
        // to exist
        if (getBytecodeSize(0x91ae842A5Ffd8d12023116943e72A606179294f3) == 0) {
            TokenDescriptorBytecode tbc = new TokenDescriptorBytecode();
            address TBCAddr = deployContractFromBytecode(tbc.UNISWAP_V3_TOKEN_DESCRIPTOR_BYTECODE());
            vm.etch(address(0x91ae842A5Ffd8d12023116943e72A606179294f3), getBytecode(TBCAddr));
        }

        // The address for the token descriptor is actually a proxy to the above,
        // so we need to deploy the proxy too
        if (getBytecodeSize(0xEe6A57eC80ea46401049E92587E52f5Ec1c24785) == 0) {
            TokenDescriptorProxyBytecode tpbc = new TokenDescriptorProxyBytecode();
            address TPBCAddr = deployContractFromBytecode(tpbc.UNISWAP_V3_TOKEN_DESCRIPTOR_PROXY_BYTECODE());
            vm.etch(address(0xEe6A57eC80ea46401049E92587E52f5Ec1c24785), getBytecode(TPBCAddr));
        }

        // Deploy uniswap v3 router
        if (getBytecodeSize(0xE592427A0AEce92De3Edee1F18E0157C05861564) == 0) {
            UniswapV3RouterBytecode uv3r = new UniswapV3RouterBytecode();
            // The code is identical locally or not, so we can just use the deployed
            // bytecode, even with its constructor args the same. (The args are
            // the factory address and weth address, which we have duplicated.)
            vm.etch(address(0xE592427A0AEce92De3Edee1F18E0157C05861564), uv3r.UNISWAP_V3_ROUTER_BYTECODE_DEPLOYED());
        }
        uniswapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

        // Create the Uniswap v3 pool
        if (getBytecodeSize(0xC36442b4a4522E871399CD717aBDD847Ab11FE88) == 0) {
            NonfungiblePositionManagerBytecode nfpmbc = new NonfungiblePositionManagerBytecode();
            address uniswapPositionManagerAddr =
                deployContractFromBytecode(nfpmbc.UNISWAP_V3_POSITION_MANAGER_BYTECODE());
            vm.etch(address(0xC36442b4a4522E871399CD717aBDD847Ab11FE88), getBytecode(uniswapPositionManagerAddr));
        }
        uniswapPositionManager =
            INonfungiblePositionManager(payable(address(0xC36442b4a4522E871399CD717aBDD847Ab11FE88)));

        uniswapPositionManager.createAndInitializePoolIfNecessary{ gas: 5000000 }(
            address(token), address(weth), FEE, encodePriceSqrt(1, 1)
        );

        uniswapPool = IUniswapV3Pool(uniswapFactory.getPool(address(weth), address(token), FEE));

        uniswapPool.increaseObservationCardinalityNext(40);

        // Deployer adds liquidity at current price to Uniswap V3 exchange
        weth.approve(address(uniswapPositionManager), type(uint256).max);
        token.approve(address(uniswapPositionManager), type(uint256).max);
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: address(token),
            token1: address(weth),
            tickLower: -60,
            tickUpper: 60,
            fee: FEE,
            recipient: deployer,
            amount0Desired: UNISWAP_INITIAL_WETH_LIQUIDITY,
            amount1Desired: UNISWAP_INITIAL_TOKEN_LIQUIDITY,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp * 2
        });
        uniswapPositionManager.mint{ gas: 5000000 }(params);

        // Deploy the lending pool
        lendingPool = new PuppetV3Pool(IERC20Minimal(address(token)), IERC20Minimal(address(weth)), uniswapPool);

        // Setup initial token balances of lending pool and player
        token.transfer(player, PLAYER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(lendingPool), LENDING_POOL_INITIAL_TOKEN_BALANCE);

        // Some time passes
        uint256 blockTimePreWarp = block.timestamp;
        vm.warp(block.timestamp + (3 * 24 * 60 * 60)); // 3 days in seconds
        uint256 blockTimePostWarp = block.timestamp;
        require(blockTimePostWarp >= blockTimePreWarp + (3 * 24 * 60 * 60));

        // Ensure oracle in lending pool is working as expected. At this point, DVT/WETH price should be 1:1.
        // To borrow 1 DVT, must deposit 3 ETH
        require(lendingPool.calculateDepositOfWETHRequired(1e18) == 3e18);

        // To borrow all DVT in lending pool, user must deposit three times its value
        require(
            lendingPool.calculateDepositOfWETHRequired(LENDING_POOL_INITIAL_TOKEN_BALANCE)
                == LENDING_POOL_INITIAL_TOKEN_BALANCE * 3
        );

        // Ensure player doesn't have that much ETH
        require(player.balance < LENDING_POOL_INITIAL_TOKEN_BALANCE * 3);

        sleeper = new SleepViaVMWarp();

        initialBlockTimestamp = block.timestamp;
    }

    function test_PuppetV3() public {
        vm.startPrank(player, player);

        PuppetMasterV3 pm = new PuppetMasterV3{ value: player.balance }(
            address(token),
            address(weth),
            address(uniswapPool),
            address(lendingPool),
            address(uniswapRouter),
            address(sleeper),
            player
        );
        token.transfer(address(pm), token.balanceOf(player));
        pm.solveChallenge();

        vm.stopPrank();

        // The code below tests that your solution works. Do not edit.

        // Block timestamp must not have changed too much
        require(
            block.timestamp - initialBlockTimestamp < 115,
            "Sorry, you did not solve the challenge! Too much time has passed"
        );

        // Player has taken all tokens out of the pool
        require(
            token.balanceOf(address(lendingPool)) == 0,
            "Sorry, you did not solve the challenge! Player must take all tokens out of the pool"
        );

        require(
            token.balanceOf(player) >= LENDING_POOL_INITIAL_TOKEN_BALANCE,
            "Sorry, you did not solve the challenge! Player must take all tokens out of the pool"
        );

        console.log("Congratulations, you solved the challenge! You are the puppet (v3) master!!!");
    }

    function test_Puppet_V3() public {
        return test_PuppetV3();
    }

    function test_Puppetv3() public {
        return test_PuppetV3();
    }

    function test_Puppet_v3() public {
        return test_PuppetV3();
    }

    function test_Puppet3() public {
        return test_PuppetV3();
    }

    function test_Puppet_3() public {
        return test_PuppetV3();
    }

    function test_14() public {
        return test_PuppetV3();
    }
}
