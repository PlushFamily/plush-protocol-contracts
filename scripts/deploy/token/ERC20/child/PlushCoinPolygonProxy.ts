import hre from 'hardhat';

import { DevContractsAddresses } from '../../../../../arguments/development/consts';

async function main() {
  const PlushCoinPolygonProxy = await hre.ethers.getContractFactory(
    'UChildERC20Proxy',
  );
  const plushCoinPolygonProxy = await PlushCoinPolygonProxy.deploy(
    DevContractsAddresses.PLUSH_COIN_IMPLEMENTATION_ADDRESS,
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
      contract:
        'contracts/token/ERC20/child/PlushCoinPolygonProxy.sol:UChildERC20Proxy',
      constructorArguments: [
        DevContractsAddresses.PLUSH_COIN_IMPLEMENTATION_ADDRESS,
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
