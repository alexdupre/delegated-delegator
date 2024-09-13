# Delegated Delegator

A set of smart contracts to help automating the FTSO delegation and reward claiming, without using the private key of the ultimate owner of the tokens. The primary use case is to allow to claim FTSO rewards and next Flare distributions associated to a cold wallet. Another use case is to allow delegating to more than 2 FTSO providers without having to manage multiple accounts. The owner can define different and multiple delegator and executor addresses that can delegate and/or claim rewards on behalf of the owner, but only the owner can withdraw the funds and the rewards from the contract. Governance voting power is transferred back to the owner.

A wallet can instantiate a new `DelegatedDelegator` smart contract, by calling the `create` function of the `DelegatedDelegatorFactory` contract, and by parsing the generated `Created` event to get the new instance address.

The only parameter to be passed is:
- `description`: an optional string to identify the contract, useful for a management UI

Then it should call the `addDelegator` and `addExecutor` function to add at least a delegator and an executor account.

Either the owner or a delegator should then set the first list of FTSO providers to delegate to, using the `delegate` function.

Any address can then send wrapped tokens to the generated address, or use its `deposit` function with native tokens, to increase the contract wrapped balance, and consequentially its voting power.

The executor can periodically claim the FTSO rewards and the Flare distribution, by calling the `claimV1`, `claimV2` and `claimDistribution` functions.

Finally, only when needed, the owner can get back its funds by calling the `withdraw` or `withdrawAll` functions.

A single owner can create multiple `DelegatedDelegator` instances to split its holdings and delegate to more than 2 providers.

## Deployments

`DelegatedDelegatorFactory`
| Chain    | Address                                      |
|----------| -------------------------------------------- |
| Coston   | [0x38c6B4474Cc15fC080FaafCF37d32e822355bF26](https://coston-explorer.flare.network/address/0x38c6B4474Cc15fC080FaafCF37d32e822355bF26) |
| Coston2  | [0xe2Fb678bC1Bd259a2F5d7792F7dDD6Ecb53fa9ca](https://coston2-explorer.flare.network/address/0xe2Fb678bC1Bd259a2F5d7792F7dDD6Ecb53fa9ca) |
| Songbird | [0xE4200d40783B7e08a25a71C767792A8b564A54C9](https://songbird-explorer.flare.network/address/0xE4200d40783B7e08a25a71C767792A8b564A54C9) |
| Flare    | [0x026f603FD318d60E6C68351d6172244f3C4F6dC6](https://flare-explorer.flare.network/address/0x026f603FD318d60E6C68351d6172244f3C4F6dC6) |
