import hre from 'hardhat';

import * as args from '../../../arguments/plushController';

async function main() {
  const PlushController = await hre.ethers.getContractFactory(
    'PlushController',
  );

  const plushController = await PlushController.deploy(
    args.default[0],
    args.default[1],
  );

  await plushController.deployed();

  console.log(
    'PlushController -> deployed to address:',
    plushController.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 30s before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 30000);
    });

    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushController.address,
      contract: 'contracts/apps/PlushController.sol',
      constructorArguments: [args.default[0], args.default[1]],
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
