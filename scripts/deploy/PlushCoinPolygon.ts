import hre from 'hardhat';
import * as args from '../../arguments/plushCoinPolygon';

async function main() {
  const PlushCoinPolygon = await hre.ethers.getContractFactory('ChildERC20');
  const plushCoinPolygon = await PlushCoinPolygon.deploy(
    args.default[0],
    args.default[1],
    args.default[2],
    args.default[3],
  );

  await plushCoinPolygon.deployed();
  console.log(
    'PlushCoin Polygon -> deployed to address:',
    plushCoinPolygon.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushCoinPolygon.address,
      constructorArguments: [
        args.default[0],
        args.default[1],
        args.default[2],
        args.default[3],
      ],
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
