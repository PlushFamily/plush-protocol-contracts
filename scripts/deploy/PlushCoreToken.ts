import { ethers, upgrades, run } from 'hardhat';

async function main() {
  const PlushCoreToken = await ethers.getContractFactory('PlushCoreToken');
  const plushCoreToken = await upgrades.deployProxy(PlushCoreToken, {
    kind: 'uups',
  });

  await plushCoreToken.deployed();
  console.log('PlushCoreToken -> deployed to address:', plushCoreToken.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await run('verify:verify', {
      address: plushCoreToken.address,
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
