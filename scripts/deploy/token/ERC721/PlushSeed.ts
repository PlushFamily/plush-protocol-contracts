import { ethers, run, upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const PlushSeed = await ethers.getContractFactory('PlushSeed');
  const plushSeed = await upgrades.deployProxy(PlushSeed, {
    kind: 'uups',
  });

  await plushSeed.deployed();
  console.log('PlushSeed -> deployed to address:', plushSeed.address);

  console.log('Switch contract owner...\n');

  const changeOwner = await plushSeed.transferOwnership(
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  );

  await changeOwner.wait();

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushSeed.address,
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
