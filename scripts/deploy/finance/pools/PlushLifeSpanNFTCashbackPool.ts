import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const PlushLifeSpanNFTCashbackPool = await hre.ethers.getContractFactory(
    'PlushLifeSpanNFTCashbackPool',
  );

  const plushLifeSpanNFTCashbackPool = await upgrades.deployProxy(
    PlushLifeSpanNFTCashbackPool,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      1000000000000, // remuneration amount (in wei!)
      120, // time after which tokens will be unlocked (in sec!)
    ],
    {
      kind: 'uups',
    },
  );

  await plushLifeSpanNFTCashbackPool.deployed();

  console.log(
    'PlushNFTCashbackPool -> deployed to address:',
    plushLifeSpanNFTCashbackPool.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushLifeSpanNFTCashbackPool.address,
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
