async function main() {
  // We get the contract to deploy
  const BetGame = await ethers.getContractFactory("BetGame");
  const betGame = await BetGame.deploy();

  await betGame.deployed();

  console.log("BetGame deployed to:", betGame.address);
  const [owner] = await ethers.getSigners();
  console.log("owner", owner);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
