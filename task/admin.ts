import { task, types } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";
import aresLootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
import * as fs from "fs";

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
  console.log(ContractAddress);

  const ARESLootAddress = ContractAddress.at(-1);
  const aresLootAddress = ARESLootAddress;

  const ARESLoot = new hre.ethers.Contract(
    aresLootAddress!,
    aresLootABI,
    player
  );

  const keyFileContents = fs.readFileSync(args.filePath).toString();
  const info = keyFileContents.split("\n").filter((k) => k.length > 0);

  const playerAddrs = [];
  const playerRoles = [];

  for(let i = 0;i<info.length;i++){
    const playerInfo = info[i].split(' ');
    const addr = playerInfo[0];
    const role = playerInfo[1];
    playerAddrs.push(addr);
    playerRoles.push(role); 
  }

  
  console.log(playerAddrs);
  console.log(playerRoles);


  try {
    const receipt = await ARESLoot.batchAddRoles(
     playerAddrs,
     playerRoles
    
    );
    await receipt.wait();
    console.log('tx hash:',receipt.hash);

    const tx = await ARESLoot.hardRefreshMetadata(46);
    await tx.wait();
    console.log('tx hash:',tx.hash);

    
  } catch (e) {
    console.log(e);
  }
}
