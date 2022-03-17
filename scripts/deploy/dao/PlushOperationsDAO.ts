import hre, {upgrades} from 'hardhat';

async function main() {
  const PlushOperationsDAO = await hre.ethers.getContractFactory(
    'PlushOperationsDAO',
  );
  const plushOperationsDAO = await upgrades.deployProxy(
    PlushOperationsDAO,
    [
      "0xEaCb79ef70A5FFD4698Aa5603054e8a914cFcf12", //erc20
      "0x080190e04768F3E9939D3fa2865478b047d8F9fe", //timeLock
    ],
    {
      kind: 'uups',
    }
  );

  await plushOperationsDAO.deployed();

  console.log(
    'PlushOperationsDAO -> deployed to address:',
    plushOperationsDAO.address,
  );

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');

    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });

    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
          plushOperationsDAO.address,
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
