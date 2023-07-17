import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import "hardhat-abi-exporter"



const altlayer = {
  url: process.env.ALTLAYER_RPC_URL,
  accounts: {
    mnemonic: process.env.ALTLAYER_MNEMONIC,
  },
  chainId: Number(process.env.ALTLAYER_CHAINID),
};


const polygon = {
  url: process.env.POLYGON_RPC_URL,
  accounts: {
    mnemonic: process.env.POLYGON_MNEMONIC,
  },
  chainId: Number(process.env.POLYGON_CHAINID),
};


const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',

  networks: {
    ...(process.env.ALTLAYER_MNEMONIC? {altlayer}: undefined),
    ...(process.env.POLYGON_MNEMONIC? {polygon}: undefined),
    localhost: {
      url: 'http://localhost:8545/',
      accounts: {
        // Same mnemonic used in the .env.example
        mnemonic: process.env.TEST_MNEMONIC,
      },
      chainId: 31337,
    },



  },

  etherscan:{
    apiKey: process.env.POLYGONSCAN_API_KEY,
  },
  
  solidity: {
    version: '0.8.19',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    },
  }
};

export default config;
