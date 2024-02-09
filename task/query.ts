import { task, types } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";

import * as fs from "fs";

task("query", "get player info").setAction(queryPlayerSilver);

async function queryPlayerSilver(taskArgs: {}, hre: HardhatRuntimeEnvironment) {
  // need to force a compile for tasks
  await hre.run("compile");

  const [player] = await hre.ethers.getSigners();
  console.log(player.address);

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  // console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = await hre.ethers.getContractAt("ARESLoot", aresLootAddress!);


  const tokenId = 46;
  let owner = await ARESLoot.ownerOf(tokenId);
  let tokenURI = await ARESLoot.tokenURI(tokenId);
  console.log("Token Id -> " + tokenId);
  console.log("Owner -> " + owner);
  console.log("Token URI -> ");
  console.log(tokenURI);
}

task("analysis", "query burn <=> main").setAction(queryMetadata);

async function queryMetadata(taskArgs: {}, hre: HardhatRuntimeEnvironment) {
  // need to force a compile for tasks
  await hre.run("compile");

  const [player] = await hre.ethers.getSigners();

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = await hre.ethers.getContractAt("ARESLoot", aresLootAddress!);


  const supply = await ARESLoot.totalSupply();
  console.log(supply.toString());

  const beginTokenId = 46;
  let ids = [];
  for(let i=0;i<supply;i++){
    const id = i+beginTokenId;
    ids.push(id);
  }
  const metadata1 = await ARESLoot.bulkGetMetadata1(ids);

  for(let i = 0;i<metadata1.length;i++){
    console.log(metadata1[i].burnerAccount.toLowerCase(), metadata1[i].mainAccount.toLowerCase());
  }
}

