import { ethers, run, upgrades } from 'hardhat';

async function main() {
  const PlushAmbassador = await ethers.getContractFactory('PlushAmbassador');
  const plushAmbassador = await upgrades.deployProxy(
    PlushAmbassador,
    [
      'Plush Ambassador',
      'PLAM',
      'ipfs://QmYBiofrRjAKGxZg4518osmkzrQS24aQgZ4CKC6RyV9DDi/{id}',
      'ipfs://QmXTTH1CTkNTJe6T7NiFfQRSaUwMiKHxcbeLKJyp9WdHgz',
    ],
    {
      kind: 'uups',
    },
  );

  await plushAmbassador.deployed();
  console.log(
    'PlushAmbassador -> deployed to address:',
    plushAmbassador.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushAmbassador.address,
      ),
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
