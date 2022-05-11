import hre, { ethers, upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';
import { constants } from 'ethers';

const OPERATOR_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('OPERATOR_ROLE'),
);
const PAUSER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('PAUSER_ROLE'),
);
const UPGRADER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('UPGRADER_ROLE'),
);

async function main() {
  const PlushAccounts = await hre.ethers.getContractFactory('PlushAccounts');

  const signers = await ethers.getSigners();

  const plushAccounts = await upgrades.deployProxy(
    PlushAccounts,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      DevContractsAddresses.PLUSH_APPS_ADDRESS,
      DevContractsAddresses.PLUSH_FEE_COLLECTOR_ADDRESS,
    ],
    {
      kind: 'uups',
    },
  );

  await plushAccounts.deployed();

  console.log('PlushAccounts -> deployed to address:', plushAccounts.address);

  console.log('Grant all roles for DAO Protocol...\n');

  const grantAdminRole = await plushAccounts.grantRole(
    constants.HashZero,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // ADMIN role

  await grantAdminRole.wait();

  const grantOperatorRole = await plushAccounts.grantRole(
    OPERATOR_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // OPERATOR role

  await grantOperatorRole.wait();

  const grantPauserRole = await plushAccounts.grantRole(
    PAUSER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // PAUSER role

  await grantPauserRole.wait();

  const grantUpgraderRole = await plushAccounts.grantRole(
    UPGRADER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // UPGRADER role

  await grantUpgraderRole.wait();

  console.log('Revoke all roles from existing account...\n');

  const revokeOperatorRole = await plushAccounts.revokeRole(
    OPERATOR_ROLE,
    await signers[0].getAddress(),
  ); // OPERATOR role

  await revokeOperatorRole.wait();

  const revokeUpgraderRole = await plushAccounts.revokeRole(
    UPGRADER_ROLE,
    await signers[0].getAddress(),
  ); // UPGRADER role

  await revokeUpgraderRole.wait();

  const revokePauserRole = await plushAccounts.revokeRole(
    PAUSER_ROLE,
    await signers[0].getAddress(),
  ); // PAUSER role

  await revokePauserRole.wait();

  const revokeAdminRole = await plushAccounts.revokeRole(
    constants.HashZero,
    await signers[0].getAddress(),
  ); // ADMIN role

  await revokeAdminRole.wait();

  if (process.env.NETWORK != 'local') {
    console.log('Waiting 1m before verify contract\n');
    await new Promise(function (resolve) {
      setTimeout(resolve, 60000);
    });
    console.log('Verifying...\n');

    await hre.run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushAccounts.address,
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
