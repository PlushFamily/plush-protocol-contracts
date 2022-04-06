import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const PlushGetCoreToken = await hre.ethers.getContractFactory(
    'PlushGetCoreToken',
  );

  const plushGetCoreToken = await upgrades.deployProxy(
    PlushGetCoreToken,
    [
      DevContractsAddresses.PLUSH_CORE_TOKEN_ADDRESS,
      DevContractsAddresses.PLUSH_FEE_COLLECTOR_ADDRESS,
    ],
    {
      kind: 'uups',
    },
  );

  await plushGetCoreToken.deployed();
  console.log(
    'PlushGetCoreToken -> deployed to address:',
    plushGetCoreToken.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushGetCoreToken.address,
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
