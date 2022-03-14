import hre from 'hardhat';

async function main() {
  const PlushOperationsDAO = await hre.ethers.getContractFactory(
    'PlushOperationsDAO',
  );

  const plushOperationsDAO = await PlushOperationsDAO.deploy();
  await plushOperationsDAO.deployed();

  console.log(
    'PlushOperationsDAO -> deployed to address:',
    plushOperationsDAO.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 30s before verify contract\n');

    await new Promise(function (resolve) {
      setTimeout(resolve, 30000);
    });

    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      contract: 'contracts/dao/PlushOperationsDAO.sol',
      address: plushOperationsDAO.address,
    });
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
