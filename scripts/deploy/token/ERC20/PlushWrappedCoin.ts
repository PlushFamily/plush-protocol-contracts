import hre from 'hardhat';
import * as args from '../../../../arguments/plushCoinWrapped';

async function main() {
  const PlushWrapped = await hre.ethers.getContractFactory('PlushWrapped');
  const plushWrapped = await PlushWrapped.deploy(args.default[0]);

  await plushWrapped.deployed();
  console.log('PlushWrappedCoin -> deployed to address:', plushWrapped.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushWrapped.address,
      contract: 'contracts/token/ERC20/PlushWrapped.sol:PlushWrapped',
      constructorArguments: [args.default[0]],
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
