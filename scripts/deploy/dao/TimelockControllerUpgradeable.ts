import hre from 'hardhat';

async function main() {
  const TimelockControllerUpgradeable = await hre.ethers.getContractFactory(
    'TimelockControllerUpgradeable',
  );

  const timelockControllerUpgradeable = await TimelockControllerUpgradeable.deploy();
  await timelockControllerUpgradeable.deployed();

  console.log(
    'PlushOperationsDAO -> deployed to address:',
    timelockControllerUpgradeable.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');

    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });

    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: timelockControllerUpgradeable.address,
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
