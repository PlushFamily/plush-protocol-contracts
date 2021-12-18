import hre from 'hardhat';
import * as args from '../../arguments/plushCoreTokenPolygon';

async function main() {
  const PlushCoreTokenPolygon = await hre.ethers.getContractFactory(
    'PlushCoreTokenChild',
  );
  const plushCoreTokenPolygon = await PlushCoreTokenPolygon.deploy(
    args.default[0],
    args.default[1],
    args.default[2],
  );

  await plushCoreTokenPolygon.deployed();
  console.log(
    'plushCoreToken Polygon -> deployed to address:',
    plushCoreTokenPolygon.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushCoreTokenPolygon.address,
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
