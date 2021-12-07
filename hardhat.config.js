/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const {RINKEBY_API_URL, MUMBAI_API_URL, PRIVATE_KEY, ETHERSCAN_API_KEY} = process.env;

module.exports = {
    defaultNetwork: "rinkeby",
    networks: {
        hardhat: {},
        development: {
            url: "http://127.0.0.1:7545"
        },
        rinkeby: {
            url: RINKEBY_API_URL,
            accounts: [`0x${PRIVATE_KEY}`]
        },
        mumbai: {
            url: MUMBAI_API_URL,
            accounts: [`0x${PRIVATE_KEY}`]
        },
    },
    solidity: {
        version: "0.8.7",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY
    }
}