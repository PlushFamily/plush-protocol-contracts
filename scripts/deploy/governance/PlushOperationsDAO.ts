import hre, { upgrades, ethers } from 'hardhat';
import web3 from 'web3';
import * as args from '../../../arguments/plushOperationsDAO';

const MINDELAY = 60 * 60 * 24 * 3;
const ZERO_ADDRESS = web3.utils.padLeft(0, 40);
const PROPOSER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('PROPOSER_ROLE'),
);
const TIMELOCK_ADMIN_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('TIMELOCK_ADMIN_ROLE'),
);

async function main() {
  const [unlockOwner] = await ethers.getSigners();

  const PlushTimeLock = await hre.ethers.getContractFactory('PlushTimeLock');

  const plushTimeLock = await upgrades.deployProxy(PlushTimeLock, [
    MINDELAY,
    [], // proposers list is empty at deployment
    [ZERO_ADDRESS], // allow any address to execute a proposal once the timelock has expired
  ]);

  await plushTimeLock.deployed();

  console.log('> PlushTimeLock -> deployed to address:', plushTimeLock.address);

  const PlushOperationsDAO = await hre.ethers.getContractFactory(
    'PlushOperationsDAO',
  );

  // deploy plushOperationsDAO proxy
  const plushOperationsDAO = await upgrades.deployProxy(
    PlushOperationsDAO,
    [args.default[0], plushTimeLock.address],
    { kind: 'uups' },
  );

  await plushOperationsDAO.deployed();

  console.log(
    '> PlushOperationsDAO -> deployed to address:',
    plushOperationsDAO.address,
  );

  // plushOperationsDAO should be the only proposer
  await plushTimeLock.grantRole(PROPOSER_ROLE, plushOperationsDAO.address);

  await new Promise(function (resolve) {
    setTimeout(resolve, 10000);
  });

  console.log(
    '> PlushOperationsDAO added to Timelock as sole proposer. ',
    `${plushOperationsDAO.address} is Proposer: ${await plushTimeLock.hasRole(
      PROPOSER_ROLE,
      plushOperationsDAO.address,
    )} `,
  );

  // deployer should renounced the Admin role after setup (leaving only Timelock as Admin)
  await plushTimeLock.renounceRole(TIMELOCK_ADMIN_ROLE, unlockOwner.address);

  await new Promise(function (resolve) {
    setTimeout(resolve, 10000);
  });

  console.log(
    '> Plush Owner recounced Admin Role. ',
    `${unlockOwner.address} isAdmin: ${await plushTimeLock.hasRole(
      TIMELOCK_ADMIN_ROLE,
      unlockOwner.address,
    )} `,
  );

  if (process.env.NETWORK != 'local') {
    console.log('> Waiting 1m before verify contracts\n');

    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });

    console.log('> Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushTimeLock.address,
      ),
    });

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
