<p align="center">
<a href="https://github.com/PlushFamily/plush-protocol-contracts" target="blank"><img src="https://avatars.githubusercontent.com/u/74625046?s=200&v=4" width="120" alt="Plush Logo" /></a>
</p>

<p align="center">Plush Protocol is the core of the Plush ecosystem.</p>
    <p align="center">
<a href="https://www.npmjs.com/package/@plushfamily/plush-protocol-contracts" target="_blank"><img src="https://img.shields.io/npm/v/@plushfamily/plush-protocol-contracts.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/package/@plushfamily/plush-protocol-contracts"><img src="https://img.shields.io/npm/l/@plushfamily/plush-protocol-contracts.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/package/@plushfamily/plush-protocol-contracts"><img src="https://img.shields.io/npm/dm/@plushfamily/plush-protocol-contracts.svg" alt="NPM Downloads" /></a>
<a href="https://twitter.com/plush_family_" target="_blank"><img src="https://img.shields.io/twitter/follow/plush_family_.svg?style=social&label=Follow" alt="twitter"></a>

## Description

This repository contains the Plush Protocol contracts and the development environment of Plush Protocol.

Import this library to connect your contracts to the Plush ecosystem.

## Overview

### Installation

```console
npm install @plushfamily/plush-protocol-contracts
```

### Description of protocol contracts

- **PlushApps** - the main contract of the ecosystem. It contains the addresses of the current applications of the ecosystem.
- **PlushAccounts** - using to simplify transactions in the ecosystem and the storage of application tokens.
- **PlushController** - the main contract of a third-party application. Used to connect app to the Plush ecosystem.
- **Plush** - ERC-20 ecosystem token (***PLSH***).
- **WrappedPlush** - wrapped ERC-20 ecosystem token (***wPLSH***).
- **LifeSpan** - ERC-721 LifeSpan token (***LIFESPAN***).
- **PlushGetLifeSpan** - self-minting of LifeSpan token (***LIFESPAN***).
- **PlushFaucet** - ERC-20 ecosystem token faucet (***PLSH***).

## Using

### Protocol importing

Once installed, you can use the contracts in the library by importing them:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@plushfamily/plush-protocol-contracts/contracts/templates/apps/PlushController.sol";

contract PlushForestController is PlushController {}
```
_Example of importing a controller._

### Connecting third-party app to the Plush ecosystem

To add your application to the ecosystem, you need to write the address of the deployed controller contract in a special form (the form will be published later).

Example of connecting a third-party application to the Plush ecosystem: [Plush Studio Contracts](https://github.com/PlushStudio/plush-studio-contracts)

## Development of the Plush Protocol

We will be glad if you join the protocol development!

### Project structure

`arguments` directory with current contract addresses for each of the environments.

`contracts` directory with source code of contracts

`scripts` directory with scripts for deploying and upgrading contracts

`hardhat.config.ts` hardhat configuration

### Preparation for development

First you need to make sure that the Node.js platform is installed.

**Recommended using the 16 version NodeJS!**

Link to download: [download Node.js](https://nodejs.org)

Next, you need to install the yarn package manager: `npm install --global yarn`

Before starting the project, you need to install all project dependencies: `yarn install`


### Configuration

Create `.env` file:
```
NETWORK = mumbai
API_URL = "https://eth-mumbai.alchemyapi.io/v2/x-L3PRORMY7KyYFFMH9Gny4YD4sDxe5T" # EXAMPLE
PRIVATE_KEY = "ETH_PRIVATE_KEY"
ETHERSCAN_API_KEY = "ETHERSCAN_KEY"
POLYGONSCAN_API_KEY = "POLYGONSCAN_KEY"
DEFENDER_TEAM_API_KEY="KEY"
DEFENDER_TEAM_API_SECRET_KEY="KEY"
```
_You can use any Blockchain provider : Alchemy, Infura, etc._

Support networks:
1. Goerli – `goerli`
2. Mumbai – `mumbai`
3. Mainnet ETH – `mainnet`
4. Polygon mainnet – `polygon`
5. Local – `local` # for Ganache

### Where to get the required keys

Get api keys on [Etherscan](https://docs.etherscan.io/getting-started/viewing-api-usage-statistics) and [Polygonscan](https://polygonscan.com/myapikey) websites
To request an upgrade contracts, you need to use a [OpenZeppelin Defender](https://defender.openzeppelin.com/). 

### Deploying contracts

To deploy contract use: `npx hardhat run scripts/deploy/.../{FileName}`

### Upgrading contracts

To deploy contract use: `npx hardhat run scripts/upgrade/.../{FileName}`
