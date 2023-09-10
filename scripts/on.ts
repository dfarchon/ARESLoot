import { ethers } from "hardhat";
import lootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
import * as fs from "fs";

const { ALTLAYER_RPC_URL, ALTLAYER_PRIVATEKEY, DEPLOY_LOG, SEND_TOKEN_LOG } =
  process.env;


const provider =  new ethers.JsonRpcProvider(ALCHEMY_MAINNET_URL);

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

  const sendTokenPath = SEND_TOKEN_LOG?.toString();


//   _msgSender(), tokenId, _burnerWalletAddress, _gold);
  ARESLoot.on("Message",async (sender,tokenId,gamer,_gold)=>{

    console.log('==============================================')
    console.log('tokenId', tokenId.toString());
    console.log('gamer',gamer);
    console.log('gold',_gold.toString());

    const address = gamer.toString().toLowerCase();
    const amount = (Number(_gold)*10).toString();
    const isAddress = ethers.isAddress(address);
    try{
    if (!isAddress) {
        throw new Error(`Address ${address} is NOT a valid address.`);
      }
    }catch(e){
        console.error(e);
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
    
  })




}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
