/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const {API_URL, PRIVATE_KEY, ETHERSCAN_API_KEY} = process.env;

module.exports = {
    defaultNetwork: "rinkeby",
    networks: {
        hardhat: {},
        rinkeby: {
            url: API_URL,
            accounts: [`0x${PRIVATE_KEY}`]
        }
    },
    solidity: {
        compilers: [
            {
                version: "0.8.7",
            }
        ],
        overrides: {
            "contracts/PlushCoreToken.sol": {
                version: "0.8.7",
            },
            "contracts/PlushForestToken.sol": {
                version: "0.8.7",
            },
            "contracts/PlushLogo.sol": {
                version: "0.8.7",
            },
            "contracts/PlushGetTree.sol": {
                version: "0.8.7",
            },
            "contracts/Plai.sol": {
                version: "0.8.7",
            }
        },
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY
    }
}