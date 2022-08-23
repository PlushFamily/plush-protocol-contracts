import { ethers, run } from 'hardhat';

async function main() {
  const Ambassador = await ethers.getContractFactory('Ambassador');
  const ambassador = await Ambassador.deploy();

  await ambassador.deployed();
  console.log('Ambassador -> deployed to address:', ambassador.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await run('verify:verify', {
      address: ambassador.address,
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
