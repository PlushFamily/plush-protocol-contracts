import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const PlushAccounts = await hre.ethers.getContractFactory('PlushAccounts');

  const plushAccounts = await upgrades.deployProxy(
    PlushAccounts,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      DevContractsAddresses.PLUSH_APPS_ADDRESS,
      DevContractsAddresses.PLUSH_FEE_COLLECTOR_ADDRESS,
    ],
    {
      kind: 'uups',
    },
  );

  await plushAccounts.deployed();

  console.log('PlushAccounts -> deployed to address:', plushAccounts.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushAccounts.address,
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
