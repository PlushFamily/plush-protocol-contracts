const PlushCoin = artifacts.require("./PlushCoin.sol");
const PlushNFT = artifacts.require("./PlushNFT.sol");

module.exports = function (deployer) {
    deployer.deploy(PlushCoin, 1000);
    deployer.deploy(PlushNFT);
}