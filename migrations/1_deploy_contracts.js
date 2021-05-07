const PlushCoin = artifacts.require("PlushCoin");

module.exports = function(deployer) {
  deployer.link(PlushCoin);
  deployer.deploy(PlushCoin);
};
