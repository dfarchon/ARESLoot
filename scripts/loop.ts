import { ethers } from "hardhat";
import lootABI from "../abi/contracts/ARESLoot.sol/ARESLoot.json";
import * as fs from "fs";

const { ALTLAYER_RPC_URL, ALTLAYER_PRIVATEKEY, DEPLOY_LOG, SEND_TOKEN_LOG } =
  process.env;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

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

  console.log("Contract Address -> ", ContractAddress.at(-1));
  let cnt = 1;

  const readContractState = async () => {
    const totalSupply = await ARESLoot.totalSupply();
    console.log("============ begin Read Contract State ============ ");
    console.log("Total Supply:", totalSupply.toString());

    const state = [];

    for (let i = 1; i <= Number(totalSupply); i++) {
      const loot = await ARESLoot.ARESLootStorage(i);
      console.log(i, loot[0], loot[4].toString());

      state.push(i+' '+loot[0]+' '+ loot[4].toString());
    }

    console.log("============  end Read Contract State ============ ");
    return state;
  };

  const readLocalState = async (localFilePath: string) => {
    const localState = fs.readFileSync(localFilePath).toString();
    const goldAmountLocalRecord = localState
      .split("\n")
      .filter((k) => k.length > 0);
    return goldAmountLocalRecord;
  };

  let newestLocalStatePath = "./local/loop-1690094317586";
  while (1) {
    console.log("============ Loop " + cnt + " begin ============");

    const contractState = await readContractState();
    const accounts = [];
    const goldAmountInContract = [];

    for (let i = 0; i < contractState.length; i++) {
      const state = contractState[i]
        .toString()
        .split(" ")
        .filter((k) => k.length > 0);
        console.log(state[1],state[2]);
       accounts.push(state[1].toString());
       goldAmountInContract.push(state[2].toString());
    }

    const goldAmountInLocal = await readLocalState(newestLocalStatePath);

    let needTokenAmount = 0;

    for (let i = 0; i < goldAmountInContract.length; i++) {
      const _gold = Number(goldAmountInContract[i]);
      const _goldLocal =
        i < goldAmountInLocal.length ? Number(goldAmountInLocal[i]) : 0;
      // const  _account = accounts[i];

      const delta = _gold - _goldLocal;
      needTokenAmount += 10*delta;
    }
    console.log("Need Token Amount -> " + needTokenAmount.toString() + " $RES");
    const balance = await altlayerProvider.getBalance(altlayerAdmin.address);
    console.log("Admin Balance -> ", ethers.formatEther(balance) + " $RES");

    let needTokenAmountInWei = ethers.getBigInt(
      ethers.parseUnits(needTokenAmount.toString()),
    );

    if (needTokenAmountInWei > balance) {
      console.log("Admin Need More Token");
      break;
    }

    let log = "";

    for (let i = 0; i < goldAmountInContract.length; i++) {
      const _gold = Number(goldAmountInContract[i]);
      const _goldLocal =
        i < goldAmountInLocal.length ? Number(goldAmountInLocal[i]) : 0;
      const _account = accounts[i];

      const delta = _gold - _goldLocal;

      log += _gold.toString() + "\n";
      console.log("Token Id ->", i + 1);
      if (delta > 0) {
        const address = _account;
        const amount = (Number(delta) * 10).toString();

        const isAddress = ethers.isAddress(address);

        if (!isAddress) {
          console.error(`Address ${address} is NOT a valid address.`);
          // throw new Error(`Address ${address} is NOT a valid address.`);
        }

        console.log(address + "," + amount);

        const tx = await altlayerAdmin.sendTransaction({
            to: address,
            value: ethers.parseEther(amount),
        });

        await tx.wait();
        const balance = await altlayerProvider.getBalance(
          altlayerAdmin.address,
        );
        console.log("Admin Balance: ", ethers.formatEther(balance) + " $RES");
        const balance2 = await altlayerProvider.getBalance(address);
        console.log(
          "Receiver Balance: ",
          ethers.formatEther(balance2) + " $RES",
        );
        console.log("-------------------------------------------------");
      }
    }

    const newLog = "./local/loop-" + Date.now().toString();
    console.log(newLog);
 
    const showTime = new Date();
    console.log(showTime);
    newestLocalStatePath = newLog;
    fs.writeFileSync(newLog, log, { flag: "a" });


    console.log('Wait for 1 Min ...');
    console.log('You can stop here ...');
    await sleep(60*1000);

  }


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
