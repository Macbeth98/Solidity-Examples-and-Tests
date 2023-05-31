import { expect } from "chai";
import { ethers } from 'hardhat';
import { Counter } from "../typechain-types";

describe("Counter", () => {

  console.log("counter");

  let counter: Counter;

  beforeEach(async () => { 
    const Counter = await ethers.getContractFactory('Counter');
    counter = await Counter.deploy('Count Apes', 1);
  })

  describe("Counter Constructor", () => {
    it('sets the initial count', async () => {
  
      expect(await counter.count()).to.be.equal(1);
    });

    it('sets the Counter Name', async () => {
      expect(await counter.countName()).to.be.equal("Count Apes");
    })
  })

  describe("Counting", () => {
    it('Increment the Count', async() => {
      const transaction = await counter.incrementCount();
      await transaction.wait();

      expect(await counter.count()).to.be.equal(2);
    })

    it('decrements the count', async () => {
      const transaction = await counter.decrementCount();
      await transaction.wait();

      expect(await counter.count()).to.be.equal(0);
    })

    it('Expect the decrement to be reverted', async () => {
      const transaction = await counter.decrementCount();
      await transaction.wait();
      
      await expect(counter.decrementCount()).to.be.reverted;
    })
  })

  

})