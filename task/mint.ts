
import { task, types } from 'hardhat/config';
import type { HardhatRuntimeEnvironment } from 'hardhat/types';
import * as fs from "fs";

const GAS_ADJUST_DELTA = '0.00000005';
const overrides = {
  gasPrice: Number(parseFloat(GAS_ADJUST_DELTA) * parseInt('5000000000')).toString(),
};

task("mint", "mint NFT")
  .setAction(mint);

  async function mint(taskArgs:{},hre: HardhatRuntimeEnvironment) {
    // need to force a compile for tasks
    await hre.run('compile');
    
    const [account1,account2] = await hre.ethers.getSigners();
    const filePath = process.env.DEPLOY_LOG?.toString();

    const fileContents = fs.readFileSync(filePath!).toString();
    const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
   
    const ARESLootAddress = ContractAddress.at(-1);
    console.log('contract address: ',ARESLootAddress);
    const aresLootAddress = ARESLootAddress;

    const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

    console.log('ok');
    console.log(account1.address);

    const tx = await ARESLoot.mint(
        account2.address,
        'DFAresHero',
        'Dark Forest Community',
        overrides
    );
   
    await tx.wait();
    console.log("tx hash:" + tx.hash);
    console.log("mint success");
    
    const tokenId = 90;
    let owner = await ARESLoot.ownerOf(tokenId);
  let tokenURI = await ARESLoot.tokenURI(tokenId);
  console.log("Token Id -> " + tokenId);
  console.log("Owner -> " + owner);
  console.log("Token URI -> ");
  console.log(tokenURI);


  }