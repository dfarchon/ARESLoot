
import { task, types } from 'hardhat/config';
import type { HardhatRuntimeEnvironment } from 'hardhat/types';
import aresLootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
import * as fs from "fs";


task("mint", "mint NFT")
  .setAction(mint);

  async function mint(taskArgs:{},hre: HardhatRuntimeEnvironment) {
    // need to force a compile for tasks
    await hre.run('compile');
    
    const [account1, account2] = await hre.ethers.getSigners();
    const filePath = process.env.DEPLOY_LOG?.toString();

    const fileContents = fs.readFileSync(filePath!).toString();
    const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
    // console.log(ContractAddress);
    const ARESLootAddress = ContractAddress.at(-1);
    console.log('contract address: ',ARESLootAddress);
    const aresLootAddress = ARESLootAddress;
    
    const ARESLoot = new hre.ethers.Contract(aresLootAddress!, aresLootABI, account1);


    const tx0 = await account1.sendTransaction({
        to: account2.address,
        value: hre.ethers.parseEther("10.0"), // Sends exactly 10.0 ether
      });

    await tx0.wait();
    console.log("tx hash:" + tx0.hash);
    console.log('send ether successfully');

    
    const tx1 = await ARESLoot.thaw();
    await tx1.wait();
    console.log("tx hash:" + tx1.hash);
    console.log("thaw success");

    console.log('burner account: ', account1.address);
    console.log('main account: ',account2.address);
    const tx2 = await ARESLoot.setMainAccount(account2.address);
    await tx2.wait();
  
  

    const tx = await ARESLoot.connect(account2).mint(
        account1.address,
        'DFAres Player',
        'Dark Forest Community',
    );
   
    await tx.wait();
    console.log("tx hash:" + tx.hash);
    console.log("mint success");
    
    const tokenId = 46;
    let owner = await ARESLoot.ownerOf(tokenId);
  let tokenURI = await ARESLoot.tokenURI(tokenId);
  console.log("Token Id -> " + tokenId);
  console.log("Owner -> " + owner);
  console.log("Token URI -> ");
  console.log(tokenURI);


  }