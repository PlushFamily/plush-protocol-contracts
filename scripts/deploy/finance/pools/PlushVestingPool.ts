import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const PlushVestingPool = await hre.ethers.getContractFactory(
    'PlushVestingPool',
  );

  const plushVestingPool = await upgrades.deployProxy(
    PlushVestingPool,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      '10000', //Percent release at IDO (1000 = 1%)
      '15', //How many days will it be unlocked
    ],
    {
      kind: 'uups',
    },
  );

  await plushVestingPool.deployed();

  console.log(
    'PlushVestingPool -> deployed to address:',
    plushVestingPool.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushVestingPool.address,
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
