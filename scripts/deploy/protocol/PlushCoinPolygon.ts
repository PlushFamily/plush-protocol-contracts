import hre from 'hardhat';

async function main() {
  const PlushCoinPolygon = await hre.ethers.getContractFactory('UChildERC20');
  const plushCoinPolygon = await PlushCoinPolygon.deploy();

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
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
