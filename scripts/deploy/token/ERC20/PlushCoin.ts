import hre from 'hardhat';

async function main() {
  const Plush = await hre.ethers.getContractFactory('Plush');
  const plush = await Plush.deploy();

  await plush.deployed();
  console.log('PlushCoin -> deployed to address:', plush.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plush.address,
      contract: 'contracts/token/ERC20/Plush.test.ts:Plush',
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
