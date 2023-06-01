import { expect } from "chai";
import { ethers } from 'hardhat';
import { FlashLoan, FlashLoanReceiver, Token } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const tokens = (amount: Number) => {
  return ethers.utils.parseUnits(amount.toString(), "ether")
}

const toEther = (amount: any) => {
  return Number(ethers.utils.formatEther(amount));
}

describe('FlashLoan', async () => { 

  const tokenName = 'MAN';
  const tokenSymbol = 'MAN';
  const totalSupply = 10000;

  let deployer: SignerWithAddress;

  let token: Token;
  let flashLoan:FlashLoan;
  let flashLoanReceiver: FlashLoanReceiver

  const depositTokens = async () => {
    const transaction = await flashLoan.connect(deployer).depositTokens(tokens(totalSupply));
    await transaction.wait();
  }

  beforeEach(async () => {  

    const accounts = await ethers.getSigners();
    deployer = accounts[0];

    // Fetching contracts Instances
    const FlashLoan = await ethers.getContractFactory('FlashLoan');
    const FlashLoanReceiver = await ethers.getContractFactory('FlashLoanReceiver');
    const Token = await ethers.getContractFactory('Token');

    // Deploy token
    token = await Token.deploy(tokenName, tokenSymbol, totalSupply);

    // Deploy the flashLoan
    flashLoan = await FlashLoan.deploy(token.address);

    const transaction = await token.connect(deployer).approve(flashLoan.address, tokens(totalSupply));
    await transaction.wait();

    await depositTokens();

    // Deploy the FlashLoanReceiver
    flashLoanReceiver = await FlashLoanReceiver.deploy(flashLoan.address);
  })

  describe('Deployment', () => {
    it('Token check', async () => {
      expect(await token.name()).to.be.equal(tokenName);
      expect(await token.symbol()).to.be.equal(tokenSymbol);
      expect(await token.totalSupply()).to.be.equal(tokens(totalSupply));
    })

    it('FlashLoan Check', async () => {
      expect(await flashLoan.token()).to.be.equal(token.address);
    })

    it ('verifies the tokens deposit', async () => {
      expect(await token.balanceOf(flashLoan.address)).to.be.equal(tokens(totalSupply));
    })
  })

  describe('Borrowing Funds', () => {
    it('Borrrow funds from the pool',async () => {
      let amount = tokens(100);
      let transaction = await flashLoanReceiver.connect(deployer).executeFlashLoan(amount);
      await transaction.wait();

      await expect(transaction).to.emit(flashLoanReceiver, 'LoanReceived').withArgs(token.address, amount);
    })
  })

 })