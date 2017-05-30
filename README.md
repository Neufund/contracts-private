# Contracts [![Build Status](https://travis-ci.org/Neufund/Contracts.svg?branch=master)](https://travis-ci.org/Neufund/Contracts)

[![Greenkeeper badge](https://badges.greenkeeper.io/Neufund/contracts-private.svg?token=eed4b4c2552e2916a6094f2262231d9c1fe7d3c5c2a7efca019be2bbce44239b&ts=1493976140055)](https://greenkeeper.io/)
Neufund smart contracts


# Build and test

*On testrpc*:
```
git clone https://github.com/Neufund/Contracts.git
cd Contracts
npm install
npm run testrpc &
npm run test
npm run deploy
```

*Using solc*: Truffle currently does not handler syntax errors
 nicely. To check the contracts for errors, you can run:
```
solc ./contracts/*.sol ./contracts/*/*.sol
```

# Repositories of contracts

These are collections of contracts for reference:

## Package managers

* https://www.ethpm.com/registry/packages
* https://www.npmjs.com/search?q=solidity
* https://dapple.readthedocs.io/en/master/packages/

## Collections

* https://github.com/OpenZeppelin/zeppelin-solidity
* https://github.com/axic/density
* https://github.com/ethereum/dapp-bin/tree/master/library
* https://github.com/androlo/standard-contracts/
* https://github.com/ethereum/solidity/tree/develop/std

## Libraries

* https://github.com/ConsenSys/Token-Factory
* https://github.com/ConsenSys/MultiSigWallet
* https://github.com/Arachnid/solidity-stringutils

## Projects

* https://github.com/ethereum/dapp-bin
* https://github.com/ethereum/ens
* https://github.com/melonproject/melon
* https://github.com/golemfactory/golem-crowdfunding
* https://github.com/makerdao/maker-otc/blob/master/contracts
* https://github.com/ConsenSys/gnosis-contracts
* https://github.com/ConsenSys/singulardtv-contracts
* https://github.com/ConsenSys/repsys-contracts
* https://github.com/ConsenSys/btcrelay


# Guidelines to writing contracts

The overall design is Multi-contract & Multi-state. Contracts have owners and
owners can update references to other contracts.


* https://ethereum.stackexchange.com/questions/8551/methodological-security-review-of-a-smart-contract/8593#8593
* https://ethereum.stackexchange.com/questions/6204/writing-secure-smart-contracts-in-solidity
* https://eprint.iacr.org/2016/633.pdf

https://blog.ethereum.org/2017/01/07/introduction-light-client-dapp-developers/
TODO: ERC with `getLogEvents(logKeys[], uint firstBlock, uint lastBlock)`

// See: https://ethereum.stackexchange.com/questions/9745/is-there-any-way-for-a-contract-to-know-when-it-gets-sent-a-token
simple upload test
