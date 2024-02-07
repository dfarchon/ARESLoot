import { task, types } from 'hardhat/config';
import type { HardhatRuntimeEnvironment } from 'hardhat/types';
import * as fs from "fs";

task("deploy", "deploy contracts")
  .setAction(deploy);

  async function deploy(taskArgs:{},hre: HardhatRuntimeEnvironment) {
    // need to force a compile for tasks
    await hre.run('compile');
    
    const [deployer] = await hre.ethers.getSigners();


    const balance = await hre.ethers.provider.getBalance(deployer.address);
    const etherAmount = hre.ethers.formatEther(balance);
    console.log("Account: " + deployer.address);
    console.log(hre.ethers.formatEther(balance), "ETH");
 
    const Loot = await hre.ethers.getContractFactory("ARESLoot");
    // test
    // const gameAddress ='0x8950bab77f29e8f81e6f78aea0a79badd88eeb13';
    // round 2 
    const gameAddress = '0x9bebf120d985cb8835634e3c8565d320f79aac76';
    const loot = await Loot.deploy(gameAddress);
  
    await loot.waitForDeployment();
    console.log("Contract Address -> ");
    console.log(loot.target.toString().toLowerCase());
    const content = loot.target.toString().toLowerCase() + "\n";

    const filePath = process.env.DEPLOY_LOG?.toString();

    fs.writeFileSync(filePath!, content, { flag: "a" });
  
  }