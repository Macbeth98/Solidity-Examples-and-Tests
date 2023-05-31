import { expect } from "chai";
import { ethers } from "hardhat"
import { Escrow, RealEstate } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const tokens = (amount: Number) => {
  return ethers.utils.parseUnits(amount.toString(), "ether")
}

const toEther = (amount: any) => {
  return Number(ethers.utils.formatEther(amount));
}

describe('RealEstate', () => {

  let realEstate: RealEstate, escrow: Escrow;

  let deployer: SignerWithAddress, buyer: SignerWithAddress, seller: SignerWithAddress;
  let inspector: SignerWithAddress, lender: SignerWithAddress;
  let nftId = 1;
  let purchasePrice = tokens(10), escrowAmount = tokens(5);

  beforeEach(async () => {

    const accounts = await ethers.getSigners();
    deployer = accounts[0];
    seller = deployer;
    buyer = accounts[1];
    inspector = accounts[2];
    lender = accounts[3];

    const RealEstate = await ethers.getContractFactory("RealEstate");
    const Escrow = await ethers.getContractFactory("Escrow");

    realEstate = await RealEstate.deploy();
    escrow = await Escrow.deploy(realEstate.address, nftId, seller.address, buyer.address, inspector.address, lender.address, purchasePrice, escrowAmount);

    const transaction = await realEstate.connect(seller).approve(escrow.address, nftId);
    await transaction.wait();
  })

  const depositEarnest = async () => {
    const transaction = await escrow.connect(buyer).depositEarnest({ value: escrowAmount });
    await transaction.wait();
  }

  const passInspection = async () => {
    const transaction = await escrow.connect(inspector).updateInspectionStatus(true);
    await transaction.wait();

    expect(await escrow.inspectionPassed()).to.be.equal(true);
  }

  const approveSale = async (account: SignerWithAddress) => {
    const transaction = await escrow.connect(account).approveSale();
    await transaction.wait();
  }

  describe('Deployment', async () => {
    it('sends an NFT to the seller / deployer', async () => {
      expect(await realEstate.ownerOf(nftId)).to.be.equal(seller.address);
    })
  })

  describe('Selling real Estate', () => {

    it('buyer deposits the Earnest Amount', async () => {

      await depositEarnest();

      const balance = await escrow.getBalance();
      expect(balance).to.be.equal(escrowAmount);
    });

    it('Inspector Updates Status', passInspection);

    it('executes a successful transaction', async () => {
      expect(await realEstate.ownerOf(nftId)).to.equal(seller.address);

      await passInspection();

      await depositEarnest();

      await approveSale(buyer);
      await approveSale(seller);

      const lendFunds = await lender.sendTransaction({ to: escrow.address, value: purchasePrice.sub(escrowAmount) });
      await lendFunds.wait();

      await approveSale(lender);

      console.log('Buyer finalizes the sale');

      const sellerBalance = await seller.getBalance();

      const transaction = await escrow.connect(buyer).finalizeSale();
      await transaction.wait();

      expect(await realEstate.ownerOf(nftId)).to.be.equal(buyer.address);
      expect(toEther(await seller.getBalance())).to.be.equal(toEther(sellerBalance) + toEther(purchasePrice));
    })

  })

})