import hre from 'hardhat';

async function main() {
  const PlushCoin = await hre.ethers.getContractFactory('PlushCoin');
  const plushCoin = await PlushCoin.deploy();

  await plushCoin.deployed();
  console.log('PlushCoin -> deployed to address:', plushCoin.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
