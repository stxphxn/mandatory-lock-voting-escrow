import { HardhatUserConfig } from "hardhat/config";
import "hardhat-contract-sizer";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-vyper";

const config = require("./config.js");

const hhconfig: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  vyper: {
    compilers: [
      {
        version: "0.3.7",
      },
    ],
  },

  defaultNetwork: "hardhat",

  networks: {
    hardhat: {
      forking: {
        url: "https://polygon-mumbai-bor.publicnode.com",
        enabled: false,
      },
    },
    taiko: {
      url: config.rpcUrl,
      accounts: config.mainnetAccounts,
    },
  },

  // docs: https://www.npmjs.com/package/@nomiclabs/hardhat-etherscan
  etherscan: {
    customChains: [
      {
        network: "taiko",
        chainId: 167000,
        urls: {
          apiURL: "https://api.taikoscan.io/api",
          browserURL: "https://taikoscan.io/",
        },
      },
    ],
    apiKey: {
      taiko: config.apiKeyTaikoscan,

      // to get all supported networks
      // npx hardhat verify --list-networks
    },
  },
};

export default hhconfig;
