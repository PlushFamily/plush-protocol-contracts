import { ethers, upgrades, run } from 'hardhat';

async function main() {
  const LifeSpan = await ethers.getContractFactory('LifeSpan');
  const lifeSpan = await upgrades.deployProxy(LifeSpan, {
    kind: 'uups',
  });

  await lifeSpan.deployed();
  console.log('LifeSpan -> deployed to address:', lifeSpan.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        lifeSpan.address,
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
