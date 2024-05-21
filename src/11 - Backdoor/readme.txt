
https://www.damnvulnerabledefi.xyz/challenges/backdoor/


Challenge #11 - Backdoor

To incentivize the creation of more secure wallets in their team, someone has
deployed a registry of Gnosis Safe** wallets. When someone in the team deploys
and registers a wallet, they will earn 10 DVT tokens.

To make sure everything is safe and sound, the registry tightly integrates with
the legitimate Gnosis Safe Proxy Factory,*** and has some additional safety
checks.

Currently there are four people registered as beneficiaries: Alice, Bob,
Charlie and David. The registry has 40 DVT tokens in balance to be distributed
among them.

Your goal is to take all funds from the registry. In a single transaction.


**  https://github.com/gnosis/safe-contracts/blob/v1.3.0/contracts/GnosisSafe.sol

*** https://github.com/gnosis/safe-contracts/blob/v1.3.0/contracts/proxies/GnosisSafeProxyFactory.sol



See the contracts:
https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v3.0.0/contracts/backdoor

Complete the challenge:
https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/backdoor/backdoor.challenge.js


< version v3.0.0 >
created by @tinchoabbate - maintained by The Red Guild (https://theredguild.org/)
