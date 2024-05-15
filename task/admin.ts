import { task, types } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";
import * as fs from "fs";

const GAS_ADJUST_DELTA = '0.00000005';
const overrides = {
  gasPrice: Number(parseFloat(GAS_ADJUST_DELTA) * parseInt('5000000000')).toString(),
};

task("admin:batchSetRoles", "admin batch set roles")
  .addPositionalParam(
    "filePath",
    "the path to the file containing keys to disable",
    undefined,
    types.string
  )
  .setAction(adminBatchSetRoles);

async function adminBatchSetRoles(
  args: { filePath: string },
  hre: HardhatRuntimeEnvironment
) {
  const [player] = await hre.ethers.getSigners();
  console.log(player.address);

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  // console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;
  console.log('AresLoot address:',aresLootAddress);

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  const keyFileContents = fs.readFileSync(args.filePath).toString();
  const info = keyFileContents.split("\n").filter((k) => k.length > 0);

  const playerAddrs = [];
  const playerRoles = [];

  for (let i = 0; i < info.length; i++) {
    const playerInfo = info[i].split(" ");
    const addr = playerInfo[0];
    const role = playerInfo[1];
    playerAddrs.push(addr);
    playerRoles.push(role);
  }

  console.log(playerAddrs);
  console.log(playerRoles);

  try {
    const receipt = await ARESLoot.batchAddRoles(playerAddrs, playerRoles,overrides);
    console.log("tx hash:", receipt.hash);
    console.log('submit...');
    await receipt.wait();
    console.log('successful');

 
  } catch (e) {
    console.log(e);
  }
}

task("adminChangeName", "admin change name")
  .addPositionalParam("id", "tokenId", undefined, types.string)
  .addPositionalParam("player", "player name", undefined, types.string)
  .addPositionalParam("team", "team name", undefined, types.string)
  .setAction(adminChangeName);

async function adminChangeName(
  args: { id: string; player: string; team: string },
  hre: HardhatRuntimeEnvironment
) {
  const [player] = await hre.ethers.getSigners();
  console.log(player.address);

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  try {
    const receipt = await ARESLoot.adminChangeName(
      args.id,
      args.player,
      args.team,
      overrides
    );
    await receipt.wait();
    console.log("tx hash:", receipt.hash);

    const tx = await ARESLoot.hardRefreshMetadata(46);
    await tx.wait();
    console.log("tx hash:", tx.hash);
  } catch (e) {
    console.log(e);
  }
}

task("adminChangeMainAccount", "admin change main account")
  .addPositionalParam("id", "tokenId", undefined, types.string)
  .addPositionalParam("mainaccount","main account",undefined,types.string)
  .setAction(adminChangeMainAccount);

async function adminChangeMainAccount(
  args: { id: string; mainaccount:string },
  hre: HardhatRuntimeEnvironment
) {
  const [player] = await hre.ethers.getSigners();
  console.log(player.address);

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  // console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  try {
    const receipt = await ARESLoot.adminChangeMainAccount(
      args.id,
      args.mainaccount,
      overrides
    );
    await receipt.wait();
    console.log("tx hash:", receipt.hash);

    const tx = await ARESLoot.hardRefreshMetadata(46);
    await tx.wait();
    console.log("tx hash:", tx.hash);
  } catch (e) {
    console.log(e);
  }
}


task("freeze", "admin freeze")
  .setAction(freeze);

async function freeze(
  args: { },
  hre: HardhatRuntimeEnvironment
) {
  const [player] = await hre.ethers.getSigners();
  console.log(player.address);

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  // console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  try {
    const receipt = await ARESLoot.freeze(overrides);
    await receipt.wait();
    console.log("tx hash:", receipt.hash);
  } catch (e) {
    console.log(e);
  }
}


task("thaw", "admin thaw")
  .setAction(thaw);

async function thaw(
  args: { },
  hre: HardhatRuntimeEnvironment
) {
  const [player] = await hre.ethers.getSigners();
  console.log(player.address);

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  // console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  try {
    const receipt = await ARESLoot.thaw(overrides);
    await receipt.wait();
    console.log("tx hash:", receipt.hash);
  } catch (e) {
    console.log(e);
  }
}



task("hardrefreshburneraccount", "hard refresh burner account")
.addPositionalParam("account", "burner account", undefined, types.string)
  .setAction(hardRefreshBurnerAccount);

async function hardRefreshBurnerAccount(
  args: { account:string },
  hre: HardhatRuntimeEnvironment
) {

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  // console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  try {
    console.log('burner account:',args.account);

    const tokenId = await ARESLoot.getMinted(args.account);
    console.log('token Id:',tokenId);
    const receipt = await ARESLoot.hardRefreshMetadata(tokenId,overrides);
    await receipt.wait();
    console.log('refresh successfully');
    const tokenURI = await ARESLoot.tokenURI(tokenId);
    console.log('tokenURI:');
    console.log(tokenURI);


  } catch (e) {
    console.log(e);
  }
}


task("tokenURI", "hard refresh burner account")
.addPositionalParam("id", "tokenId", undefined, types.string)
  .setAction(getTokenURI);

async function getTokenURI(
  args: { id:string },
  hre: HardhatRuntimeEnvironment
) {

  const filePath = process.env.DEPLOY_LOG?.toString();

  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  // console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = await hre.ethers.getContractAt("AresEpic", aresLootAddress!);

  try {
  

    const tokenId = args.id.toString();
    console.log('token Id:',tokenId);
    const receipt = await ARESLoot.hardRefreshMetadata(tokenId,overrides);
    await receipt.wait();
    console.log('refresh successfully');
    const tokenURI = await ARESLoot.tokenURI(tokenId);
    console.log('tokenURI:');
    console.log(tokenURI);


  } catch (e) {
    console.log(e);
  }
}