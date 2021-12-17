import hre from 'hardhat';

async function main() {
  const PlushGetTree = await hre.ethers.getContractFactory('PlushGetTree');
  const plushGetTree = await PlushGetTree.deploy(
    '0xd5015643F38A06b2962283Ec0B9fF555812Adcd0', // Forest address
    '0x8663f80619Cbc4562FF8e0986917429E917C79ba', // Plush Coin address
    '0x5d367Ba836ce0C90E9fd3D58E0A7aCb6f63Dc7b1', // withdrawal address, need to change
  );

  await plushGetTree.deployed();
  console.log('PlushGetTree -> deployed to address:', plushGetTree.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
