import hre, { ethers, upgrades } from 'hardhat';
import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const PlushRewardYear = await hre.ethers.getContractFactory(
    'PlushRewardYear',
  );

  const plushRewardYear = await upgrades.deployProxy(
    PlushRewardYear,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      DevContractsAddresses.LIFESPAN_ADDRESS,
      DevContractsAddresses.PLUSH_BLACKLIST,
      DevContractsAddresses.PLUSH_ACCOUNTS_ADDRESS,
      ethers.utils.parseUnits('1', 18),
      ethers.utils.parseUnits('12', 18),
    ],
    {
      kind: 'uups',
    },
  );

  await plushRewardYear.deployed();

  console.log(
    'PlushRewardYear -> deployed to address:',
    plushRewardYear.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushRewardYear.address,
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
