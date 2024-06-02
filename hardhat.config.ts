import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomiclabs/hardhat-solhint";
import "solidity-coverage";
import * as dotenv from "dotenv";


dotenv.config();

// Hardhat configuration
const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // If you want to do some forking, uncomment this
      // forking: {
      //   url: MAINNET_RPC_URL
      // }
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    polygonAmoy: {
      url: process.env.POLYGON_AMOY_RPC as string,
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: "auto",
    },
    zircuit: {
      url: `https://zircuit1.p2pify.com`,
      accounts: [process.env.PRIVATE_KEY as string]
    }


  },
  etherscan: {
    apiKey: {
      polygonAmoy: process.env.OKLINK_AMOY_API as string,
    },
    customChains: [
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL:
            "https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy",
          browserURL: "https://www.oklink.com/polygonAmoy",
        },
      },
    ],
  },
  sourcify: {
    enabled: false
  },
  namedAccounts: {
    deployer: {
      default: 0, // Default is the first account
      mainnet: 0,
    },
    owner: {
      default: 0,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.25",
      },
    ],
  },
};

export default config;