import { ethers } from "hardhat";

async function deploy() {
  const MintyplexDomain = "0x3e802F9208004aAc98088D939834c3B1FF9a4d8f";
  const Mintyplex = await ethers.deployContract("Mintyplex", [MintyplexDomain]);

  await Mintyplex.waitForDeployment();

  console.log(`Mintyplex deployed to ${Mintyplex.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
deploy().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
