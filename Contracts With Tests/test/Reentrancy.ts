import { expect } from "chai";
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { Attacker, Bank } from "../typechain-types";
import { BigNumberish } from "ethers";

const fromEther = (value: string | Number) => {
  return ethers.utils.parseEther(value.toString());
}

const toEther = (value: BigNumberish) => {
  return Number(ethers.utils.formatEther(value));
}

describe('Renetrancy', () => { 
  let deployer: SignerWithAddress;
  let user: SignerWithAddress;
  let attacker: SignerWithAddress;
  let bank: Bank;
  let attackerContract: Attacker

  beforeEach(async () => {

    let accounts = await ethers.getSigners();
    deployer = accounts[0];
    user = accounts[1];
    attacker = accounts[2];

    const Bank = await ethers.getContractFactory('Bank', deployer);
    bank = await Bank.deploy();

    await bank.deposit({ value: fromEther('100') })

    await bank.connect(user).deposit({ value: fromEther('50') });

    const Attacker = await ethers.getContractFactory('Attacker', attacker);
    attackerContract = await Attacker.deploy(bank.address);
  })

  describe('deposit and withdraw', () => {
    it('accepts deposits', async () => {
      const deployerBalance = await bank.balance(deployer.address);
      expect(deployerBalance).to.eq(fromEther('100'));

      const userBalance = await bank.balance(user.address);
      expect(userBalance).to.be.equal(fromEther('50'));
    })

    it('accepts withdraw', async () => {
      await bank.withdraw();

      await bank.connect(user).withdraw();

      expect(await bank.balance(deployer.address)).to.be.eq(0);
      expect(await bank.balance(user.address)).to.be.eq(0);
    })
  })

  describe('Attacker', () => {

    it('Allows Attacker drain funds from withdraw', async () => {
      const bankBalance =  toEther(await ethers.provider.getBalance(bank.address));
      console.log("Bank Balance...", bankBalance);

      expect(bankBalance).to.be.eq(150);

      const attackerBalance = toEther(await ethers.provider.getBalance(attacker.address));
      console.log('Attackers Balance...', attackerBalance);

      await attackerContract.attack({ value: fromEther(10) });


      // After balances;
      console.log(`Bank Balance...`, toEther(await ethers.provider.getBalance(bank.address)));
      console.log(`Attackers Balance...`, toEther(await ethers.provider.getBalance(attacker.address)));
    })

  })
})