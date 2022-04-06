import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const PlushCoinWallets = await hre.ethers.getContractFactory(
    'PlushCoinWallets',
  );

  const plushCoinWallets = await upgrades.deployProxy(
    PlushCoinWallets,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      DevContractsAddresses.PLUSH_APPS_ADDRESS,
      DevContractsAddresses.PLUSH_FEE_COLLECTOR_ADDRESS,
    ],
    {
      kind: 'uups',
    },
  );

  await plushCoinWallets.deployed();

  console.log(
    'PlushCoinWallets -> deployed to address:',
    plushCoinWallets.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushCoinWallets.address,
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
