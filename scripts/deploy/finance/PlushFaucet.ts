import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const PlushFaucet = await hre.ethers.getContractFactory('PlushFaucet');

  const plushFaucet = await upgrades.deployProxy(
    PlushFaucet,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      DevContractsAddresses.PLUSH_CORE_TOKEN_ADDRESS,
      DevContractsAddresses.PLUSH_COIN_WALLETS_ADDRESS,
    ],
    {
      kind: 'uups',
    },
  );

  await plushFaucet.deployed();
  console.log('PlushFaucet -> deployed to address:', plushFaucet.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushFaucet.address,
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
