const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BetGame", function () {
  it("test", async () => {
    const BetGame = await ethers.getContractFactory("BetGame");
    const betGame = await BetGame.deploy();
    const contract = await betGame.deployed();

    (
      await contract.addLiquidity({
        value: ethers.utils.parseEther("10"),
      })
    ).wait();

    expect(await contract.getLiquidity()).to.equal(
      ethers.utils.parseEther("10")
    );

    (
      await contract.bet(
        [
          ethers.utils.parseEther("1"),
          ethers.utils.parseEther("2"),
          ethers.utils.parseEther("3"),
          0,
          0,
          0,
        ],
        {
          // Bet FISH
          value: ethers.utils.parseEther("2"),
        }
      )
    ).wait();

    expect(await contract.getLiquidity()).to.equal(
      ethers.utils.parseEther("0")
    );
  });
});
