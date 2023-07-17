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

  let goldAmount = 1;
  let gloryAmount = 1;
  let total = goldAmount + gloryAmount;
  let overrides = {
    value: ethers.parseUnits(total.toString(), "ether"),
    // gasLimit: 2000000
  };

  const addr = BURNER_WALLET_ADDRESS?.toString();
  const tx = await ARESLoot.mint(
    addr!,
    "DF Archon",
    goldAmount,
    gloryAmount,
    overrides,
  );

  await tx.wait();
  console.log("tx hash:" + tx.hash);
  console.log("claim success");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
