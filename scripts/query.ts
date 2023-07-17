import { ethers } from "hardhat";
import lootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
import * as fs from "fs";

const {BURNER_WALLET_ADDRESS} = process.env;

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

  const tokenId = 2;

  let owner = await ARESLoot.ownerOf(tokenId);
  let tokenURI = await ARESLoot.tokenURI(tokenId);
  console.log("Token Id -> " + tokenId);
  console.log("Owner -> " + owner);
  console.log("Token URI -> ");
  console.log(tokenURI);

  const addr = BURNER_WALLET_ADDRESS?.toString();
  let rank = await ARESLoot.rank(addr!);
 
  
  console.log("Rank -> " + rank.toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
