import { ethers } from "hardhat";
import lootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
import * as fs from "fs";


const {ALTLAYER_RPC_URL,ALTLAYER_PRIVATEKEY} = process.env;

async function main() {


  // On Layer 1
  const [addr] = await ethers.getSigners();
  const filePath = process.env.DEPLOY_LOG?.toString();
  const fileContents = fs.readFileSync(filePath!).toString();
  const ContractAddress = fileContents.split("\n").filter((k) => k.length > 0);
//   console.log(ContractAddress);
  const ARESLootAddress = ContractAddress.at(-1);
  const ARESLoot = new ethers.Contract(ARESLootAddress!, lootABI, addr);

  // On AltLayer
  const altlayerProvider = new ethers.JsonRpcProvider(ALTLAYER_RPC_URL);
  const altlayerAdmin = new ethers.Wallet(ALTLAYER_PRIVATEKEY!, altlayerProvider);


  console.log('Contract Address ->');
  console.log(ContractAddress);

  const block = await ethers.provider.getBlockNumber();
  console.log('block number -> ',block);
  const messageEvents = await ARESLoot.queryFilter('Message');


//   console.log(messageEvents);

  for(let i = 0;i<messageEvents.length;i++){
    const event = messageEvents[i];
    
    const  address = event.args[2].toString().toLowerCase();
    const amount = event.args[4].toString();

 
    console.log(address);

    
    const isAddress = ethers.isAddress(address);

    if(!isAddress){
        throw new Error(`Address ${address} is NOT a valid address.`);
    }

    console.log('address:', address);


    const tx = await altlayerAdmin.sendTransaction({
      to: address,
      value: ethers.parseEther(amount), 
    });

    await tx.wait();
    const balance = await altlayerProvider.getBalance(altlayerAdmin.address);
    console.log('admin balance:', ethers.formatEther(balance));
    const balance2 = await altlayerProvider.getBalance(address);
    console.log('receive account balance: ', ethers.formatEther(balance2));
    console.log('-------------------------------------------------');
    break;
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






