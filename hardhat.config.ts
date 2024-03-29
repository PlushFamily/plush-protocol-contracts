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
  API_URL,
  PRIVATE_KEY,
  ETHERSCAN_API_KEY,
  POLYGONSCAN_API_KEY,
  DEFENDER_TEAM_API_KEY,
  DEFENDER_TEAM_API_SECRET_KEY,
} = process.env;

if (
  !NETWORK ||
  !API_URL ||
  !PRIVATE_KEY ||
  !ETHERSCAN_API_KEY ||
  !POLYGONSCAN_API_KEY ||
  !DEFENDER_TEAM_API_KEY ||
  !DEFENDER_TEAM_API_SECRET_KEY
) {
  throw new Error('Not all variables are specified in the env file!');
}

if (
  !['cloud', 'local', 'goerli', 'mumbai', 'mainnet', 'polygon'].includes(
    NETWORK,
  )
) {
  throw new Error('Network not supported!');
}

let TEST_CLOUD_ACCOUNT_PRIVATE_KEY_1 = PRIVATE_KEY;
let TEST_CLOUD_ACCOUNT_PRIVATE_KEY_2 = PRIVATE_KEY;
let TEST_CLOUD_ACCOUNT_PRIVATE_KEY_3 = PRIVATE_KEY;

if (NETWORK == 'cloud') {
  TEST_CLOUD_ACCOUNT_PRIVATE_KEY_1 =
    process.env.TEST_CLOUD_ACCOUNT_PRIVATE_KEY_1 || '';
  TEST_CLOUD_ACCOUNT_PRIVATE_KEY_2 =
    process.env.TEST_CLOUD_ACCOUNT_PRIVATE_KEY_2 || '';
  TEST_CLOUD_ACCOUNT_PRIVATE_KEY_3 =
    process.env.TEST_CLOUD_ACCOUNT_PRIVATE_KEY_3 || '';
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
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.8.15',
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
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/token/ERC1155/PlushAmbassador.sol': {
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/finance/PlushGetAmbassador.sol': {
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/token/ERC721/LifeSpan.sol': {
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/finance/PlushAccounts.sol': {
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/finance/PlushGetLifeSpan.sol': {
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/finance/PlushFaucet.sol': {
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/PlushApps.sol': {
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/templates/apps/PlushController.sol': {
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/governance/PlushBlacklist.sol': {
        version: '0.8.16',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      'contracts/governance/PlushOperationsDAO.sol': {
        version: '0.8.16',
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
  defaultNetwork: NETWORK,
  networks: {
    local: {
      url: 'http://127.0.0.1:8545',
      accounts: [
        '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
        '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d',
      ], // Just for the test. Do not use these keys in public networks!
    },
    cloud: {
      url: API_URL,
      accounts: [
        TEST_CLOUD_ACCOUNT_PRIVATE_KEY_1,
        TEST_CLOUD_ACCOUNT_PRIVATE_KEY_2,
        TEST_CLOUD_ACCOUNT_PRIVATE_KEY_3,
      ],
    },
    goerli: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    mumbai: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    mainnet: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    polygon: {
      url: API_URL,
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
