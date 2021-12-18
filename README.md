# Plush Token Development

This repository contains the source code for Ethereum contracts.

## Project structure
`contracts` directory with source code of contracts

`contracts/old` directory with source code of old contracts

`scripts` directory with description of the deployment process

`hardhat.config.ts` hardhat configuration

## Installation

First you need to make sure that the Node.js platform is installed.

Link to download: [install Node.js](https://nodejs.org/en/)

Next, you need to install the yarn package manager: `npm install --global yarn`

Before starting the project, you need to install all project dependencies: `yarn install`


## Configuration

Create `.env` file:
```
NETWORK = rinkeby # or goerli, mumbai
RINKEBY_API_URL = "https://eth-rinkeby.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T"
GOERLI_API_URL = "https://eth-rinkeby.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T"
MUMBAI_API_URL = "https://eth-mumbai.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T"
PRIVATE_KEY = "ETH_PRIVATE_KEY"
ETHERSCAN_API_KEY = "ETHERSCAN_KEY"
POLYGONSCAN_API_KEY = "ETHERSCAN_KEY"
```

## Using

Deploy contract:
`npx hardhat run scripts/deploy/{ScriptName}`
