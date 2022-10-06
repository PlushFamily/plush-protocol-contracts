import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const PlushGetAmbassador = await hre.ethers.getContractFactory(
    'PlushGetAmbassador',
  );

  const plushGetAmbassador = await upgrades.deployProxy(
    PlushGetAmbassador,
    [
      DevContractsAddresses.PLUSH_AMBASSADOR,
      DevContractsAddresses.PLUSH_BLACKLIST,
    ],
    {
      kind: 'uups',
    },
  );

  await plushGetAmbassador.deployed();
  console.log(
    'PlushGetAmbassador -> deployed to address:',
    plushGetAmbassador.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushGetAmbassador.address,
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
