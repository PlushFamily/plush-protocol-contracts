import hre from 'hardhat';
import * as args from '../../arguments/plushCoinPolygonProxyArgs';

async function main() {
  const PlushCoinPolygonProxy = await hre.ethers.getContractFactory(
    'UChildERC20Proxy',
  );
  const plushCoinPolygonProxy = await PlushCoinPolygonProxy.deploy(
    args.default[0],
  );

  await plushCoinPolygonProxy.deployed();
  console.log(
    'PlushCoin Polygon Proxy -> deployed to address:',
    plushCoinPolygonProxy.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushCoinPolygonProxy.address,
      contract: 'contracts/PlushCoinPolygonProxy.sol:UChildERC20Proxy',
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
