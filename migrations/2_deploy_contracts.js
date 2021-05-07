const PlushCoin = artifacts.require("./PlushCoin.sol");
const PlushNFT = artifacts.require("./PlushNFT.sol");

module.exports = function (deployer, network, accounts) {
    const userAddress = accounts[3];
    deployer.deploy(PlushCoin, userAddress);
    deployer.deploy(PlushNFT);
}