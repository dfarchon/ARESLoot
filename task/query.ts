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

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  const tokenId = 90;
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

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  const supply = await ARESLoot.totalSupply();
  console.log(supply.toString());

  const beginTokenId = 90;
  let ids = [];
  for (let i = 0; i < supply; i++) {
    const id = i + beginTokenId;
    ids.push(id);
  }
  const metadata1 = await ARESLoot.bulkGetMetadata1(ids);

  for (let i = 0; i < metadata1.length; i++) {
    console.log(
      metadata1[i].burnerAccount.toLowerCase(),
      metadata1[i].mainAccount.toLowerCase()
    );
  }
}

task("contributor", "analysis contributor")
  .addPositionalParam(
    "filePath",
    "the path to the file",
    undefined,
    types.string
  )
  .setAction(analysisContributor);

async function analysisContributor(
  args: { filePath: string },
  hre: HardhatRuntimeEnvironment
) {
  // need to force a compile for tasks
  await hre.run("compile");

  const [player] = await hre.ethers.getSigners();

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;
  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  const keyFileContents = fs.readFileSync(args.filePath).toString();
  const info = keyFileContents.split("\n").filter((k) => k.length > 0);

  for (let i = 0; i < info.length; i++) {
    const contributorInfo = info[i].split(" ");
    const name = contributorInfo[0];
    const burnerAccount = contributorInfo[1];
    if (hre.ethers.isAddress(burnerAccount)) {
      const mintId = await ARESLoot.getMinted(burnerAccount);
      const formatId = mintId.toString();
      if (formatId !== "0") {
        console.log(name, burnerAccount, formatId);
      } else {
        console.log(name, burnerAccount, "not mint yet");
      }
    } else console.log(name, "No burner account");
  }
}
