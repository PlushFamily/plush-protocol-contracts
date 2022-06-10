import hre, { upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const PlushVestingSeedInvestorsPool = await hre.ethers.getContractFactory(
    'PlushVestingSeedInvestorsPool',
  );

  const plushVestingSeedInvestorsPool = await upgrades.deployProxy(
    PlushVestingSeedInvestorsPool,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS, //plushCoin
      '0x6d40F09fa1678aEDFBB59416B1Ab50E34672Ee61', //usdt
      '0xD50aEb7325779258280E2dD0d7a94a9c2C904254', //usdc
      '0x58a99BD5f7974320A17F1e95e92DFC674506D9A4', //DAO wallet
      '3000000000000000000000', //reserved price
      '500000000000000000000000', //full price
      '10000', //Percent release at IDO (1000 = 1%)
      '450', //How many days will it be unlocked
    ],
    {
      kind: 'uups',
    },
  );

  await plushVestingSeedInvestorsPool.deployed();

  console.log(
    'PlushVestingSeedInvestorsPool -> deployed to address:',
    plushVestingSeedInvestorsPool.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushVestingSeedInvestorsPool.address,
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
