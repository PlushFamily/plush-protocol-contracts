import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const PlushNFTCashbackPool = await hre.ethers.getContractFactory(
    'PlushNFTCashbackPool',
  );

  const plushNFTCashbackPool = await upgrades.deployProxy(
    PlushNFTCashbackPool,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      100, // remuneration amount (in wei!)
      100, // time after which tokens will be unlocked (in sec!)
    ],
    {
      kind: 'uups',
    },
  );

  await plushNFTCashbackPool.deployed();

  console.log(
    'PlushNFTCashbackPool -> deployed to address:',
    plushNFTCashbackPool.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushNFTCashbackPool.address,
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
