import hre from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const WrappedPlush = await hre.ethers.getContractFactory('WrappedPlush');
  const wrappedPlush = await WrappedPlush.deploy(
    DevContractsAddresses.PLUSH_COIN_ADDRESS,
  );

  await wrappedPlush.deployed();
  console.log('WrappedPlush -> deployed to address:', wrappedPlush.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: wrappedPlush.address,
      contract: 'contracts/token/ERC20/WrappedPlush.sol:WrappedPlush',
      constructorArguments: [DevContractsAddresses.PLUSH_COIN_ADDRESS],
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
