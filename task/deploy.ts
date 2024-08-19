import { task, types } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";
import * as fs from "fs";

const GAS_ADJUST_DELTA = '0.00000005';
const overrides = {
  gasPrice: Number(parseFloat(GAS_ADJUST_DELTA) * parseInt('5000000000')).toString(),
};

task("deploy", "deploy contracts").setAction(deploy);

async function deploy(taskArgs: {}, hre: HardhatRuntimeEnvironment) {
  // need to force a compile for tasks
  await hre.run("compile");

  const [deployer] = await hre.ethers.getSigners();
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Account: " + deployer.address);
  console.log(hre.ethers.formatEther(balance), "ETH");

  const Loot = await hre.ethers.getContractFactory("AresEpic");
  // test 
  // const gameAddress = '0x500cf53555c09948f4345594f9523e7b444cd67e';
  // round 2
  // const gameAddress = '0x9bebf120d985cb8835634e3c8565d320f79aac76';
  // round 3
  // const gameAddress = '0x78978d53e07e8a45830e2a623a3c58e2e1fecd4c';
  // round 4 
  const gameAddress = '0x962847b239b1103d4c8b4eb67bc663ac32a6aeb7';

  const loot = await Loot.deploy(gameAddress,overrides);

  await loot.waitForDeployment();
  console.log("Contract Address -> ");
  console.log(loot.target.toString().toLowerCase());
  const content = loot.target.toString().toLowerCase() + "\n";
  const filePath = process.env.DEPLOY_LOG?.toString();
  fs.writeFileSync(filePath!, content, { flag: "a" });
}
