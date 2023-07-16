import { ethers } from "hardhat";
import * as fs from "fs";

async function main() {
  const [deployer] = await ethers.getSigners();

  const balance = await ethers.provider.getBalance(deployer.address);
  const etherAmount = ethers.formatEther(balance);
  console.log("Account: " + deployer.address);
  console.log("Balance: " + etherAmount + " ether");

  const Loot = await ethers.getContractFactory("ARESLoot");
  const loot = await Loot.deploy();
  await loot.waitForDeployment();

  console.log("Contract Address -> ");
  console.log(loot.target.toString().toLowerCase());
  const content = loot.target.toString().toLowerCase() + "\n";

  const filePath = process.env.DEPLOY_LOG?.toString();

  fs.writeFileSync(filePath!, content, { flag: "a" });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
