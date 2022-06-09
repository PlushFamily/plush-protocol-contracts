import hre, { ethers, upgrades } from 'hardhat';
import { constants } from 'ethers';

import { DevContractsAddresses } from '../../arguments/development/consts';

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
  const PlushApps = await hre.ethers.getContractFactory('PlushApps');
  const plushApps = await upgrades.deployProxy(PlushApps, {
    kind: 'uups',
  });
  await PlushApps.deploy();
  console.log('PlushApps -> deployed to address:', plushApps.address);

  console.log('Grant all roles for DAO Protocol...\n');

  const grantAdminRole = await plushApps.grantRole(
    constants.HashZero,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // ADMIN role

  await grantAdminRole.wait();

  const grantOperatorRole = await plushApps.grantRole(
    OPERATOR_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // OPERATOR role

  await grantOperatorRole.wait();

  const grantPauserRole = await plushApps.grantRole(
    PAUSER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // PAUSER role

  await grantPauserRole.wait();

  const grantUpgraderRole = await plushApps.grantRole(
    UPGRADER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // UPGRADER role

  await grantUpgraderRole.wait();

  console.log('Revoke all roles from existing account...\n');

  const signers = await ethers.getSigners();

  const revokeOperatorRole = await plushApps.revokeRole(
    OPERATOR_ROLE,
    await signers[0].getAddress(),
  ); // OPERATOR role

  await revokeOperatorRole.wait();

  const revokeUpgraderRole = await plushApps.revokeRole(
    UPGRADER_ROLE,
    await signers[0].getAddress(),
  ); // UPGRADER role

  await revokeUpgraderRole.wait();

  const revokePauserRole = await plushApps.revokeRole(
    PAUSER_ROLE,
    await signers[0].getAddress(),
  ); // PAUSER role

  await revokePauserRole.wait();

  const revokeAdminRole = await plushApps.revokeRole(
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
        plushApps.address,
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
