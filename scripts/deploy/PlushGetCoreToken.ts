import hre from 'hardhat';
import * as args from '../../arguments/plushGetCoreTokenArgs';

async function main() {
  const PlushGetCoreToken = await hre.ethers.getContractFactory(
    'PlushGetCoreToken',
  );

  const plushGetCoreToken = await PlushGetCoreToken.deploy(
    args.default[0],
    args.default[1],
  );

  await plushGetCoreToken.deployed();
  console.log(
    'PlushGetCoreToken -> deployed to address:',
    plushGetCoreToken.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushGetCoreToken.address,
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
