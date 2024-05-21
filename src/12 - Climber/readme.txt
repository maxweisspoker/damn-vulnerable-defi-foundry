
https://www.damnvulnerabledefi.xyz/challenges/climber/


Challenge #12 - Climber

There’s a secure vault contract guarding 10 million DVT tokens. The vault is
upgradeable, following the UUPS pattern.**

The owner of the vault, currently a timelock contract, can withdraw a very
limited amount of tokens every 15 days.

On the vault there’s an additional role with powers to sweep all tokens in
case of an emergency.

On the timelock, only an account with a “Proposer” role can schedule actions
that can be executed 1 hour later.

To pass this challenge, take all tokens from the vault.


** https://eips.ethereum.org/EIPS/eip-1822


See the contracts:
https://github.com/tinchoabbate/damn-vulnerable-defi/tree/v3.0.0/contracts/climber

Complete the challenge:
https://github.com/tinchoabbate/damn-vulnerable-defi/blob/v3.0.0/test/climber/climber.challenge.js


< version v3.0.0 >
created by @tinchoabbate - maintained by The Red Guild (https://theredguild.org/)
