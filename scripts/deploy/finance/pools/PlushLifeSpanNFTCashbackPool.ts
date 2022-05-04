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
      '34000000000000000000', // remuneration amount (in wei!) default: 34 tokens
      '31556952', // time after which tokens will be unlocked (in sec!) default: 1 year
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
