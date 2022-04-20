import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const PlushGetLifeSpan = await hre.ethers.getContractFactory(
    'PlushGetLifeSpan',
  );

  const plushGetLifeSpan = await upgrades.deployProxy(
    PlushGetLifeSpan,
    [
      DevContractsAddresses.LIFESPAN_ADDRESS,
      DevContractsAddresses.PLUSH_FEE_COLLECTOR_ADDRESS,
    ],
    {
      kind: 'uups',
    },
  );

  await plushGetLifeSpan.deployed();
  console.log(
    'PlushGetLifeSpan -> deployed to address:',
    plushGetLifeSpan.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushGetLifeSpan.address,
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
