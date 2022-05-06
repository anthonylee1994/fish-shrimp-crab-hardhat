const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BetGame", function () {
  it("Buying big", async function () {
    const BetGame = await ethers.getContractFactory("BetGame");
    const betGame = await BetGame.deploy();
    const contract = await betGame.deployed();

    const tx = await contract.callStatic.bet(true, {
      value: ethers.utils.parseEther("0.1"),
    });

    expect(tx).to.equal(true);
  });

  it("open", async function () {
    const BetGame = await ethers.getContractFactory("BetGame");
    const betGame = await BetGame.deploy();
    const contract = await betGame.deployed();

    const tx = await contract.bet(true, {
      value: ethers.utils.parseEther("0.1"),
    });

    await tx.wait();

    const value = await contract.callStatic.open();

    expect(value).to.equal(true);
  });
});
