import 'hardhat-contract-sizer';
import 'dotenv/config';
import '@typechain/hardhat';
import '@nomiclabs/hardhat-waffle';
import 'solidity-coverage';
import '@nomiclabs/hardhat-etherscan';
import '@openzeppelin/hardhat-upgrades';
import '@openzeppelin/hardhat-defender';

const {
  NETWORK,
  MUMBAI_API_URL,
  GOERLI_API_URL,
  MAINNET_API_URL,
  POLYGON_API_URL,
  PRIVATE_KEY,
  ETHERSCAN_API_KEY,
  POLYGONSCAN_API_KEY,
  DEFENDER_TEAM_API_KEY,
  DEFENDER_TEAM_API_SECRET_KEY,
} = process.env;

if (
  !NETWORK ||
  !MUMBAI_API_URL ||
  !GOERLI_API_URL ||
  !MAINNET_API_URL ||
  !POLYGON_API_URL ||
  !PRIVATE_KEY ||
  !ETHERSCAN_API_KEY ||
  !POLYGONSCAN_API_KEY ||
  !DEFENDER_TEAM_API_KEY ||
  !DEFENDER_TEAM_API_SECRET_KEY
) {
  throw new Error('Not all variables are specified in the env file!');
}

if (!['local', 'goerli', 'mumbai', 'mainnet', 'polygon'].includes(NETWORK)) {
  throw new Error('Network not supported!');
}

let API_KEY = '';

if (['goerli', 'mainnet'].includes(NETWORK)) {
  API_KEY = ETHERSCAN_API_KEY;
}

if (['mumbai', 'polygon'].includes(NETWORK)) {
  API_KEY = POLYGONSCAN_API_KEY;
}

export default {
  solidity: {
    compilers: [
      {
        version: '0.8.13',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.8.9',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.8.4',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.8.2',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.6.6',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.6.2',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.6.0',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
    overrides: {
      'contracts/token/ERC20/Plush.sol': {
        version: '0.8.9',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/token/ERC20/WrappedPlush.sol': {
        version: '0.8.13',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/token/ERC721/PlushCoreToken.sol': {
        version: '0.8.9',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/finance/PlushCoinWallets.sol': {
        version: '0.8.13',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/finance/PlushGetCoreToken.sol': {
        version: '0.8.13',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/finance/PlushFaucet.sol': {
        version: '0.8.13',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/PlushApps.sol': {
        version: '0.8.13',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/templates/apps/PlushController.sol': {
        version: '0.8.13',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/governance/PlushOperationsDAO.sol': {
        version: '0.8.4',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/token/ERC20/child/PlushCoinPolygon.sol': {
        version: '0.6.6',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/token/ERC20/child/PlushCoinPolygonProxy.sol': {
        version: '0.6.6',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
    contractSizer: {
      alphaSort: true,
      runOnCompile: true,
      disambiguatePaths: false,
    },
  },
  defaultNetwork: 'local',
  networks: {
    local: {
      url: 'http://127.0.0.1:7545',
      accounts: [
        'b461e3d3ad8a749b36f778593b9295d0edbb66f10d71a03ab5b0775ee4deaf1d',
        'c0511fde3df4217dc226cd59abaa937b04ebee7250816b7aa14bdb4dfff4bf68',
      ], // Just for the test. Do not use these keys in public networks!
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
  defender: {
    apiKey: DEFENDER_TEAM_API_KEY,
    apiSecret: DEFENDER_TEAM_API_SECRET_KEY,
  },
  typechain: {
    outDir: 'types',
    target: 'ethers-v5',
  },
};
