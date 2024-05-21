
https://www.damnvulnerabledefi.xyz/challenges/wallet-mining/


Challenge #13 - Wallet Mining

There’s a contract that incentivizes users to deploy Gnosis Safe wallets,
rewarding them with 1 DVT. It integrates with an upgradeable authorization
mechanism. This way it ensures only allowed deployers (a.k.a. wards) are paid
for specific deployments. Mind you, some parts of the system have been highly
optimized by anon CT gurus.

The deployer contract only works with the official Gnosis Safe factory at
0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B and corresponding master copy at
0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F. Not sure how it’s supposed to work
though - those contracts haven’t been deployed to this chain yet.

In the meantime, it seems somebody transferred 20 million DVT tokens to
0x9b6fb606a9f5789444c17768c6dfcf2f83563801. Which has been assigned to a ward
in the authorization contract. Strange, because this address is empty as well.

Pass the challenge by obtaining all tokens held by the wallet deployer
contract. Oh, and the 20 million DVT tokens too.

Note for the Foundry Edition: Because of the way I have constructed the test
for this challenge, you need to use "--ffi --fork-block-number=1 --fork-url=YOUR_RPC_ENDPOINT"
in your forge test, as well as set the ETH_RPC_URL environment variable to that
same RPC endpoint. The reason for FFI being necessary is because I use vm.ffi
to externally call "cast" to get transaction data. The reason for the fork-block-number
is to create a new "fork" at block 1, in order to simulate a new EVM-compatible
chain with no transactions on it. The fork URL and setting ETH_RPC_URL with an
RPC address for an account with an API is necessary because the test does many cast
calls in quick succession and may get blocked or rate-limited by a free endpoint.
Alchemy, Infura, and Tenderly all provide free accounts with APIs.

IMPORTANT NOTE: whichever endpoint you decide to use needs to be an archival node,
so that cast can access data about past transactions.

An example command to run the test for this challenge might be:

  $ export ETH_RPC_URL="https://mainnet.infura.io/v3/YOUR-API-KEY-HERE"
  $ forge test --mt WalletMining -vv --ffi --fork-block-number=1 --fork-url="$ETH_RPC_URL"


See the contracts:
https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v3.0.0/contracts/wallet-mining

Complete the challenge:
https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/wallet-mining/wallet-mining.challenge.js


< version v3.0.0 >
created by @tinchoabbate - maintained by The Red Guild (https://theredguild.org/)
