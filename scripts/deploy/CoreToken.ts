import hre from 'hardhat';

async function main() {
  const PlushCoreToken = await hre.ethers.getContractFactory('PlushCoreToken');
  const plushCoreToken = await PlushCoreToken.deploy();

  await plushCoreToken.deployed();
  console.log('PlushCoreToken -> deployed to address:', plushCoreToken.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
