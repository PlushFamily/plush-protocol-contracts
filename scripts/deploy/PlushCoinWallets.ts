import hre from 'hardhat';
import * as args from '../../arguments/plushCoinWalletsArgs';

async function main() {
  const PlushCoinWallets = await hre.ethers.getContractFactory(
      'PlushCoinWallets'
  );

  const plushCoinWallets = await PlushCoinWallets.deploy(
    args.default[0],
    args.default[1],
    args.default[2],
  );

  await plushCoinWallets.deployed();

  console.log(
    'PlushCoinWallets -> deployed to address:',
    plushCoinWallets.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushCoinWallets.address,
      constructorArguments: [args.default[0], args.default[1], args.default[2]],
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
