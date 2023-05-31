# A Hardhat Project that focuses on different Smart contracts and writing Unit Test Cases for them.

This project contains different types of smart contracts. Each Smart contract has a corresponding test file where unit tests are written.

# Smart Contracts List:

-> Counter: A smart contract that can increment or decrement a given initial value. <br/>

-> Lock: A smart contract that locks the funds till certain point of time in future.<br/>

-> RealEstate: An ERC721 NFT smart contract representing a property.<br/>

-> Escrow: A smart contract that governs the rules for buying and selling of a RealEstate NFT. This is just a sample trying to mimick the real process.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
