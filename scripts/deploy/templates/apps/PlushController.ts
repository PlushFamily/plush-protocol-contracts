import hre, { upgrades } from 'hardhat';

import * as args from '../../../../arguments/plushController';

async function main() {
  const PlushController = await hre.ethers.getContractFactory(
    'PlushController',
  );

  const plushController = await upgrades.deployProxy(
    PlushController,
    [args.default[0], args.default[1]],
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
