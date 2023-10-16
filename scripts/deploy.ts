import { ethers } from "hardhat";

async function deploy() {
  const MintyplexDomain = "0x000000000000000000000000000000000000dead";
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
