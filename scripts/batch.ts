import { ethers } from "hardhat";
import lootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
import * as fs from "fs";

const { ALTLAYER_RPC_URL, ALTLAYER_PRIVATEKEY, DEPLOY_LOG, SEND_TOKEN_LOG } =
  process.env;

async function main() {
  // On Layer 1
  const [addr] = await ethers.getSigners();
  const filePath = DEPLOY_LOG?.toString();
  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
  //   console.log(ContractAddress);
  const ARESLootAddress = ContractAddress.at(-1);
  const ARESLoot = new ethers.Contract(ARESLootAddress!, lootABI, addr);

  // On AltLayer
  const altlayerProvider = new ethers.JsonRpcProvider(ALTLAYER_RPC_URL);
  const altlayerAdmin = new ethers.Wallet(
    ALTLAYER_PRIVATEKEY!,
    altlayerProvider,
  );

  console.log("Contract Address -> ",ContractAddress.at(-1));
  
  const block = await ethers.provider.getBlockNumber();
  console.log("block number -> ", block.toString());
  let messageEvents = await ARESLoot.queryFilter("Message",45191313);

  const sendTokenPath = SEND_TOKEN_LOG?.toString();
  const sendTokenContents = fs.readFileSync(sendTokenPath!).toString();
  const sendTokenLogs = sendTokenContents
    .split("\n")
    .filter((k) => k.length > 0);

  messageEvents = messageEvents.slice(sendTokenLogs.length);

  let needTokenAmount = 0;
  for (let i = 0; i < messageEvents.length; i++) {
    needTokenAmount += 10 * Number(messageEvents[i].args[3].toString());
  }

   
  console.log("Need Token Amount -> "+ needTokenAmount.toString() +" $RES");
  const balance = await altlayerProvider.getBalance(altlayerAdmin.address);
  console.log("Admin Balance -> ", ethers.formatEther(balance)+" $RES");
  console.log('Event Amount -> ',messageEvents.length);

  

  let needTokenAmountInWei = ethers.getBigInt(ethers.parseUnits(needTokenAmount.toString()));
  // console.log(needTokenAmountInWei);
  // console.log(balance);

  if(needTokenAmountInWei>balance){
    console.log("Admin Need More Token");
    return;
  }


  for (let i = 0; i < messageEvents.length; i++) {
    const event = messageEvents[i];

    const address = event.args[2].toString().toLowerCase();
    const amount = event.args[3].toString();

    const isAddress = ethers.isAddress(address);

    if (!isAddress) {
      throw new Error(`Address ${address} is NOT a valid address.`);
    }


    console.log(address+','+amount);

    const tx = await altlayerAdmin.sendTransaction({
      to: address,
      value: ethers.parseEther(amount),
    });

    await tx.wait();
    const balance = await altlayerProvider.getBalance(altlayerAdmin.address);
    console.log("Admin Balance: ", ethers.formatEther(balance)+" $RES");
    const balance2 = await altlayerProvider.getBalance(address);
    console.log("Receiver Balance: ", ethers.formatEther(balance2)+' $RES');
    console.log("-------------------------------------------------");

    const ctx = address+','+amount+'\n';
    fs.writeFileSync(sendTokenPath!,ctx,{flag:"a"});
    
  }

  //   const tokenId = 1;
  //   let owner = await ARESLoot.ownerOf(tokenId);
  //   let tokenURI = await ARESLoot.tokenURI(tokenId);
  //   console.log("Token Id -> " + tokenId);
  //   console.log("Owner -> " + owner);
  //   console.log("Token URI -> ");
  //   console.log(tokenURI);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
