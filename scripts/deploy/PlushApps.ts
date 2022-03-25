import hre, { upgrades } from 'hardhat';

async function main() {
  const PlushApps = await hre.ethers.getContractFactory('PlushApps');
  const plushApps = await upgrades.deployProxy(PlushApps, {
    kind: 'uups',
  });
  await PlushApps.deploy();
  console.log('PlushApps -> deployed to address:', plushApps.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushApps.address,
      ),
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
