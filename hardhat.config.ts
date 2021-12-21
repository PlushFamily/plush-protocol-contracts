import 'dotenv/config';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';

const {
  NETWORK,
  RINKEBY_API_URL,
  MUMBAI_API_URL,
  GOERLI_API_URL,
  MAINNET_API_URL,
  POLYGON_API_URL,
  PRIVATE_KEY,
  ETHERSCAN_API_KEY,
  POLYGONSCAN_API_KEY,
} = process.env;

if (
  !NETWORK ||
  !RINKEBY_API_URL ||
  !MUMBAI_API_URL ||
  !GOERLI_API_URL ||
  !MAINNET_API_URL ||
  !POLYGON_API_URL ||
  !PRIVATE_KEY ||
  !ETHERSCAN_API_KEY ||
  !POLYGONSCAN_API_KEY
) {
  throw new Error('Not all variables are specified in the env file!');
}

if (
  !['local', 'rinkeby', 'goerli', 'mumbai', 'mainnet', 'polygon'].includes(
    NETWORK,
  )
) {
  throw new Error('Network not supported!');
}

let API_KEY = '';

if (['rinkeby', 'goerli', 'mainnet'].includes(NETWORK)) {
  API_KEY = ETHERSCAN_API_KEY;
}

if (['mumbai', 'polygon'].includes(NETWORK)) {
  API_KEY = POLYGONSCAN_API_KEY;
}

export default {
  solidity: {
    compilers: [
      {
        version: '0.8.10',
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
    overrides: {
      'contracts/PlushCoin.sol': {
        version: '0.8.10',
      },
      'contracts/PlushCoreToken.sol': {
        version: '0.8.10',
      },
      'contracts/PlushForest.sol': {
        version: '0.8.10',
      },
      'contracts/PlushGetTree.sol': {
        version: '0.8.10',
      },
      'contracts/PlushCoinPolygon.sol': {
        version: '0.6.6',
      },
    },
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: NETWORK,
  networks: {
    local: {
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
    mainnet: {
      url: MAINNET_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    polygon: {
      url: POLYGON_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: API_KEY,
  },
};
