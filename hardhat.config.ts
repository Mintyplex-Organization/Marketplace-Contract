import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const OPTIMISM_GOERLI_URL = process.env.OPTIMISM_GOERLI_URL;
const POLYGON_RPC_URL = process.env.POLYGON_RPC_URL;

const config: HardhatUserConfig = {
  //@ts-ignore
  version: "0.8.9",
  defaultNetwork: "hardhat",
  //@ts-ignore
  settings: {
    viaIR: true,
    optimizer: {
      enabled: true,
      details: {
        yulDetails: {
          optimizerSteps: "u",
        },
      },
    },
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    localhost: {
      chainId: 31337,
      allowUnlimitedContractSize: true,
      gasPrice: 1000000000,
    },
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 11155111,
    },
    optimism_goerli: {
      url: OPTIMISM_GOERLI_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 420,
    },
    polygonMumbai: {
            url: POLYGON_RPC_URL,
            accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
            // saveDeployments: true,
            chainId: 80001,
        },
  },
  solidity: {
    compilers: [
      {
        version: "0.5.5",
      },
      {
        version: "0.8.4",
      },
      {
        version: "0.5.16",
      },
      {
        version: "0.8.9",
      },
      {
        version: "0.8.12",
      },
      {
        version: "0.8.0",
      },
      {
        version: "0.6.7",
        settings: {},
      },
      {
        version: "0.7.6",
      },
      {
        version: "0.8.1",
      },
      {
        version: "0.8.20",
      },
    ],
  },
};

export default config;
