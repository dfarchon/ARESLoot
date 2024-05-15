import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";
import "dotenv/config";

import "./task/deploy";
import "./task/query";
import "./task/mint";
import "./task/admin";
import "./task/bonus";


const { DEPLOYER_MNEMONIC } = process.env;


const localhost = {
  url: process.env.LOCALHOST_RPC_URL,
  accounts: {
    // Same mnemonic used in the .env.example
    mnemonic: process.env.DEPLOYER_MNEMONIC,
  },
  chainId: Number(process.env.LOCALHOST_CHAINID)
};

const redstoneTN = {
  url: process.env.REDSTONE_TESTNET_RPC_URL,
  accounts: {
    mnemonic: process.env.DEPLOYER_MNEMONIC,
  },
  chainId: Number(process.env.REDSTONE_TESTNET_CHAINID),
};

const redstone = {
  url: process.env.REDSTONE_RPC_URL,
  accounts: {
      mnemonic: process.env.DEPLOYER_MNEMONIC,
  },
  chainId: Number(process.env.REDSTONE_CHAINID),
}



const config: HardhatUserConfig = {
  defaultNetwork: "localhost",
  networks: {
    // Check for a DEPLOYER_MNEMONIC before we add  network to the list of networks
    ...(DEPLOYER_MNEMONIC ? { localhost } : undefined),
    ...(DEPLOYER_MNEMONIC? {redstoneTN}:undefined),
    ...(DEPLOYER_MNEMONIC? {redstone}:undefined),
  },

  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
    },
  },

};

export default config;
