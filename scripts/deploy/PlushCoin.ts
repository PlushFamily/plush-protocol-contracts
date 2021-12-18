import hre from 'hardhat';

async function main() {
  const PlushCoin = await hre.ethers.getContractFactory('PlushCoin');
  const plushCoin = await PlushCoin.deploy();

  await plushCoin.deployed();
  console.log('PlushCoin -> deployed to address:', plushCoin.address);

  const delay = (ms: number | undefined) =>
    new Promise((res) => setTimeout(res, ms));

  console.log('Waiting 30s before verify contract\n');
  await delay(30000);
  console.log('Verifying...\n');

  await hre.run('verify:verify', {
    address: plushCoin.address,
    contract: 'contracts/PlushCoin.sol:PlushCoin',
  });
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
