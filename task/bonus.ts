import { task, types } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";

import * as fs from "fs";

task("rank-bonus", "get rank bonus")
  .addPositionalParam(
    "filePath",
    "the path to the final-rank file",
    undefined,
    types.string
  )
  .setAction(getRankBonus);

async function getRankBonus(
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
  const ARESLoot = await hre.ethers.getContractAt("ARESLoot", aresLootAddress!);

  const keyFileContents = fs.readFileSync(args.filePath).toString();
  const info = keyFileContents.split("\n").filter((k) => k.length > 0);

  const getBonus = (rank: number) => {
    if (rank === 1) return 500;
    else if (rank === 2) return 300;
    else if (rank === 3) return 200;
    else if (rank >= 4 && rank <= 10) return 80;
    else return 10;
  };

  let amount = 0;
  for (let i = 0; i < info.length; i++) {
    const finalRankInfo = info[i].split(" ");
    const rank = Number(finalRankInfo[0]);
    const burnerAccount = finalRankInfo[1];
    const bonus = getBonus(rank);

    if (hre.ethers.isAddress(burnerAccount)) {
      const mintId = await ARESLoot.getMinted(burnerAccount);
      if (mintId.toString() !== "0") {
        const metadata1 = await ARESLoot.getMetadata1(mintId);
        const mainAccount = metadata1.mainAccount.toLowerCase();
        console.log(rank, burnerAccount, mainAccount, bonus);
        amount += Number(bonus);
      }
    }
  }

  console.log("amount: ", amount);
  console.log("not mint now");
  for (let i = 0; i < info.length; i++) {
    const finalRankInfo = info[i].split(" ");
    const rank = Number(finalRankInfo[0]);
    const burnerAccount = finalRankInfo[1];

    const bonus = getBonus(rank);

    if (hre.ethers.isAddress(burnerAccount)) {
      const mintId = await ARESLoot.getMinted(burnerAccount);
      if (mintId.toString() === "0") {
        console.log(rank, burnerAccount, bonus);
      }
    }
  }
}

task("boardcast-bonus", "get boardcast bonus")
  .addPositionalParam(
    "filePath",
    "the path to the final-rank file",
    undefined,
    types.string
  )
  .setAction(getBoardcastBonus);

async function getBoardcastBonus(
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
  const ARESLoot = await hre.ethers.getContractAt("ARESLoot", aresLootAddress!);

  const keyFileContents = fs.readFileSync(args.filePath).toString();
  const info = keyFileContents.split("\n").filter((k) => k.length > 0);

  for (let i = 0; i < info.length; i++) {
    const burnerAccount = info[i];
    const mintId = await ARESLoot.getMinted(burnerAccount);
    if (mintId.toString() !== "0") {
      const metadata1 = await ARESLoot.getMetadata1(mintId);
      const mainAccount = metadata1.mainAccount.toLowerCase();
      console.log(mainAccount, "9");
    }
  }

  console.log('not mint yet');
  for (let i = 0; i < info.length; i++) {
    const burnerAccount = info[i];
    const mintId = await ARESLoot.getMinted(burnerAccount);
    if (mintId.toString() === "0") {
        console.log(burnerAccount);
    }
  }
}
