import { ethers } from "hardhat";
import lootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
import * as fs from "fs";

const { BURNER_WALLET_ADDRESS } = process.env;

async function main() {
  const [admin, user] = await ethers.getSigners();
  const balance = await ethers.provider.getBalance(admin.address);

  console.log("Account balance:", balance.toString());

  const filePath = process.env.DEPLOY_LOG?.toString();


  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);

  const ARESLoot = new ethers.Contract(ARESLootAddress!, lootABI, admin);
  // console.log(ARESLoot);


  
  const rankFilePath = process.env.RANKLIST?.toString();
  const rankContents = fs.readFileSync(rankFilePath!).toString();
  const lines = rankContents.split("\n").filter(k=>k.length>0);
  // console.log(lines);

  const addrs = [];
  const ranks = [];

  for(let i = 0;i<lines.length;i++){
    const line = lines[i].split('  ');
    console.log(i+1,line[1]);

    addrs.push(line[1]);
    ranks.push(i+1);
   
  }


  const tx2 = await ARESLoot.setRank(addrs, ranks);
  await tx2.wait();
  console.log("tx hash:" + tx2.hash);

  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
