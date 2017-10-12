## Peculium token

Decentralised saving Cryptocurrency

## Requirements

To run tests you need to install the following software:

- [Truffle v3.4.9](https://github.com/trufflesuite/truffle-core)
- [EthereumJS TestRPC v4.1.1](https://github.com/ethereumjs/testrpc)
- [Zeppelin Solidity v1.2.0](https://github.com/OpenZeppelin/zeppelin-solidity)

## How to test

Open the terminal and run the following commands:

```sh
$ cd Peculium
$ npm install
$ testrpc
```

NOTE: All tests must be run separately as specified.


## Deployment
Open the terminal and run the following commands:
To deploy smart contracts to live network do the following steps:
1. Go to the smart contract folder and run truffle console:
```sh
$ cd Peculium
$ truffle console
```
2. Inside truffle console, invoke "compile" command to deploy contracts:
```sh
$ truffle> compile
$ truffle> migrate
$ truffle(development)>Peculium.deployed().then(function(instance){PCL=instance})
$ truffle(development)> PCL.owner()
 result:'0x66693d57ccc352204f3f8579e3fac774be08884b'
$ truffle(development)> PCL.balanceOf('0x66693d57ccc352204f3f8579e3fac774be08884b')
```

 ## Deploy on network Ropsten
 1. Go to contract folder
 2. solc --bin "name_of_the_contract.sol"
 3. copy Bytecode from terminal
 4. Paste Bytecode on the ethereum wallet with network Ropsten and send the contract creation transaction (you need ropsten ether)
 5. wait until the contract is added on the blockchain
 6. Communicate with the contract with ABI / JSON.
