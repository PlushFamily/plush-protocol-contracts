import hre from 'hardhat';

async function main() {
  const PlushCoin = await hre.ethers.getContractFactory('PlushCoin');
  const plushCoin = await PlushCoin.deploy();

  await plushCoin.deployed();
  console.log('PlushCoin -> deployed to address:', plushCoin.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushCoin.address,
      contract: 'contracts/PlushCoin.sol:PlushCoin',
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
