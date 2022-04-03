import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const PlushController = await hre.ethers.getContractFactory(
    'PlushController',
  );

  const plushController = await upgrades.deployProxy(
    PlushController,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      DevContractsAddresses.PLUSH_COIN_WALLETS_ADDRESS,
    ],
    {
      kind: 'uups',
    },
  );

  await plushController.deployed();

  console.log(
    'PlushController -> deployed to address:',
    plushController.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });

    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushController.address,
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
