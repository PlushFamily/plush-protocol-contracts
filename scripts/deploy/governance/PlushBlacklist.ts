import hre, { upgrades } from 'hardhat';

async function main() {
  const PlushBlacklist = await hre.ethers.getContractFactory('PlushBlacklist');
  const plushBlacklist = await upgrades.deployProxy(PlushBlacklist, {
    kind: 'uups',
  });
  await plushBlacklist.deploy();

  console.log('PlushBlacklist -> deployed to address:', plushBlacklist.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushBlacklist.address,
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
