# Plush Token Development

This repository contains the source code for Ethereum contracts.

## Project structure
`contracts` directory with source code of contracts

`contracts/old` directory with source code of old contracts

`scripts` directory with description of the deployment process

`hardhat.config.js` hardhat configuration

## Installation

First you need to make sure that the Node.js platform is installed.

Link to download: [install Node.js](https://nodejs.org/en/)

Next, you need to install the yarn package manager: `npm install --global yarn`

Before starting the project, you need to install all project dependencies: `yarn install`


## Configuration

Install the required version of Solidity in the file `hardhat.config.js`:
```
  solidity: {
    compilers: [
      {
        version: "0.8.2", // Solidity version
      }
    ]
  },
```

Select the required Ethereum network:
```
   defaultNetwork: "rinkeby", // network
   networks: {
      hardhat: {},
      rinkeby: { // network configuration description
         url: API_URL,
         accounts: [`0x${PRIVATE_KEY}`]
      }
   },
```


Create `.env` file:
```
RINKEBY_API_URL = "https://eth-rinkeby.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T"
MUMBAI_API_URL = "https://eth-mumbai.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T"
PRIVATE_KEY = "ETH_PRIVATE_KEY"
ETHERSCAN_API_KEY = "ETHERSCAN_KEY"
```

## Using

Deploy contracts:
`npx hardhat run scripts/deploy.js --network rinkeby`

Verify contracts:
`npx hardhat verify --network rinkeby <CONTRACT_ADDRESS>`
