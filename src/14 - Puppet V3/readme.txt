
https://www.damnvulnerabledefi.xyz/challenges/puppet-v3/


Challenge #14 - Puppet V3

Even on a bear market, the devs behind the lending pool (#9 - Puppet V2) kept
building.

In the latest version, they’re using Uniswap V3 as an oracle. That’s right, no
longer using spot prices! This time the pool queries the time-weighted average
price of the asset, with all the recommended libraries.

The Uniswap market has 100 WETH and 100 DVT in liquidity. The lending pool has
a million DVT tokens.

Starting with 1 ETH and some DVT, pass this challenge by taking all tokens
from the lending pool.


Note for Foundry Edition: The original challenge asks you to set an RPC endpoint,
which you can do,but this Foundry Edition works without needing to do that. The
test for this challenge is written so that it checks whether or not you are using
an RPC endpoint by checking if the needed contracts already exist, and if they do
not exist, it creates them.


See the contracts:
https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v3.0.0/contracts/puppet-v3

Complete the challenge:
https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/puppet-v3/puppet-v3.challenge.js


< version v3.0.0 >
created by @tinchoabbate - maintained by The Red Guild (https://theredguild.org/)
