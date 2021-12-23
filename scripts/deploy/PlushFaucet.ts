import hre from 'hardhat';

import * as args from '../../arguments/plushFaucetArgs';

async function main() {
  const PlushCoin = await hre.ethers.getContractFactory('PlushFaucet');
  const plushCoin = await PlushCoin.deploy(
      args.default[0]
  );

  await plushCoin.deployed();
  console.log('PlushFaucet -> deployed to address:', plushCoin.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushCoin.address,
      constructorArguments: [args.default[0]]
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
