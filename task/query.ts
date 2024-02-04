import { task, types } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";
import aresLootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
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
  console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;



  const ARESLoot = new hre.ethers.Contract(
    aresLootAddress!,
    aresLootABI,
    player
  );

  const tokenId = 46;
  let owner = await ARESLoot.ownerOf(tokenId);
  let tokenURI = await ARESLoot.tokenURI(tokenId);
  console.log("Token Id -> " + tokenId);
  console.log("Owner -> " + owner);
  console.log("Token URI -> ");
  console.log(tokenURI);
}
