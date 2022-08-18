require('dotenv').config({ debug: true });
require('@nomiclabs/hardhat-etherscan');
require('@nomiclabs/hardhat-ethers');
require('@nomicfoundation/hardhat-chai-matchers');
require('@nomiclabs/hardhat-web3');
require('@openzeppelin/hardhat-upgrades');
require('hardhat-abi-exporter');
require('hardhat-deploy');
require('hardhat-tracer');
require('hardhat-gas-reporter');
require('hardhat-contract-sizer');

const DEPLOYER_MNEMONIC = process.env.DEPLOYER_MNEMONIC;
const ALCHEMY_ACCESS_TOKEN = process.env.ACCESS_TOKEN;
const POLYGON_SCAN_API_KEY = process.env.POLYGON_SCAN_API_KEY;
const MUMBAI_SCAN_API_KEY = process.env.ETH_SCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {},
    mumbai: {
      accounts: {
        mnemonic: DEPLOYER_MNEMONIC,
      },
      url: `https://matic-mumbai.chainstacklabs.com/`,
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    polygon: {
      accounts: {
        mnemonic: DEPLOYER_MNEMONIC,
      },
      url: `wss://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_ACCESS_TOKEN}`,
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 200,
      gas: 4500000,
      gasPrice: 35000000000,
      skipDryRun: true,
    },
  },
  etherscan: {
    apiKey: {
      mumbai: MUMBAI_SCAN_API_KEY,
      polygon: POLYGON_SCAN_API_KEY,
    },
    customChains: [
      {
        network: 'mumbai',
        chainId: 80001,
        urls: {
          apiURL: 'https://api-testnet.polygonscan.com/api',
          browserURL: 'https://mumbai.polygonscan.com',
        },
      },
      {
        network: 'polygon',
        chainId: 137,
        urls: {
          apiURL: 'https://api.polygonscan.com/api',
          browserURL: 'https://polygonscan.com',
        },
      },
    ],
  },
};
