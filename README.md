# Plush Token Development

This repository contains the source code for Ethereum contracts.

## Project structure

`arguments` directory with source code of arguments for deploying contracts

`contracts` directory with source code of contracts

`contracts/old` directory with source code of old contracts

`scripts/deploy` directory with scripts for deploying contracts

`hardhat.config.ts` hardhat configuration

## Installation

First you need to make sure that the Node.js platform is installed.

Link to download: [download Node.js](https://nodejs.org/en/)

Next, you need to install the yarn package manager: `npm install --global yarn`

Before starting the project, you need to install all project dependencies: `yarn install`


## Configuration

Create `.env` file:
```
NETWORK = rinkeby # or goerli, mumbai, mainnet, polygon
RINKEBY_API_URL = "https://eth-rinkeby.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T" # EXAMPLE
GOERLI_API_URL = "https://eth-rinkeby.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T" # EXAMPLE
MUMBAI_API_URL = "https://eth-mumbai.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T" # EXAMPLE
MAINNET_API_URL = "https://eth-mainnet.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T" # EXAMPLE
POLYGON_API_URL = "https://eth-polygon.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T" # EXAMPLE
PRIVATE_KEY = "ETH_PRIVATE_KEY"
ETHERSCAN_API_KEY = "ETHERSCAN_KEY"
POLYGONSCAN_API_KEY = "POLYGONSCAN_KEY"
```

Support networks:
1. Goerli (`goerli`)
2. Mumbai (`mumbai`)
3. Mainnet ETH (`mainnet`)
4. Polygon mainnet (`polygon`)
5. Local (`local`) # for Ganache

## Using

1. Get api keys on [Etherscan](https://docs.etherscan.io/getting-started/viewing-api-usage-statistics) and [Polygonscan](https://polygonscan.com/myapikey) websites
2. It is necessary to set a working network in `.env` file in the variable `NETWORK`
3. Change the values in the contract call arguments
4. To deploy contract use: `npx hardhat run scripts/deploy/{ScriptName}`


## Deployment contracts priority

1. PlushCoin on ETH network
2. PlushCoinPolygon on Polygon network
3. PlushCoinPolygonProxy on Polygon network (with contract address args from step 2)
4. PlushCoreToken on Polygon network
5. PlushForest on Polygon network
6. PlushGetTree on Polygon network (with contract address args from step 2,5)