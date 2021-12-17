import hre from 'hardhat';

async function main() {
  const PlushForest = await hre.ethers.getContractFactory('PlushForest');
  const plushForest = await PlushForest.deploy();

  await plushForest.deployed();
  console.log('PlushForest -> deployed to address:', plushForest.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
