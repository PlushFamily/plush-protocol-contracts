import hre from 'hardhat';

async function main() {
  const PlushApps = await hre.ethers.getContractFactory('PlushApps');
  const plushApps = await PlushApps.deploy();

  await plushApps.deployed();
  console.log('PlushApps -> deployed to address:', plushApps.address);

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 30s before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 30000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: plushApps.address,
      contract: 'contracts/protocol/PlushApps.sol:PlushApps',
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
