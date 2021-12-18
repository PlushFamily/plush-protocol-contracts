import 'dotenv/config';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';

const {
  RINKEBY_API_URL,
  MUMBAI_API_URL,
  GOERLI_API_URL,
  PRIVATE_KEY,
  ETHERSCAN_API_KEY,
  POLYGONSCAN_API_KEY,
} = process.env;

if (
  !RINKEBY_API_URL ||
  !MUMBAI_API_URL ||
  !GOERLI_API_URL ||
  !PRIVATE_KEY ||
  !ETHERSCAN_API_KEY ||
  !POLYGONSCAN_API_KEY
) {
  throw new Error('Not all variables are specified in the env file!');
}

export default {
  solidity: {
    compilers: [
      {
        version: '0.8.7',
      },
      {
        version: '0.8.2',
      },
      {
        version: '0.6.6',
      },
      {
        version: '0.6.2',
      },
      {
        version: '0.6.0',
      },
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {},
    development: {
      url: 'http://127.0.0.1:7545',
    },
    rinkeby: {
      url: RINKEBY_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    goerli: {
      url: GOERLI_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    mumbai: {
      url: MUMBAI_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
