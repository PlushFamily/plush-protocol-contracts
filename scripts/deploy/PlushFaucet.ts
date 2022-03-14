import hre from 'hardhat';

import * as args from '../../arguments/plushFaucetArgs';

async function main() {
  const PlushFaucet = await hre.ethers.getContractFactory('PlushFaucet');
  const plushFaucet = await PlushFaucet.deploy(
    args.default[0],
    args.default[1],
  );

  await plushFaucet.deployed();
  console.log('PlushFaucet -> deployed to address:', plushFaucet.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 30s before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 30000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushFaucet.address,
      contract: 'contracts/PlushFaucet.sol',
      constructorArguments: [args.default[0], args.default[1]],
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
