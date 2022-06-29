import { ethers, upgrades, run } from 'hardhat';
import { constants } from 'ethers';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

const MINTER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('MINTER_ROLE'),
);
const PAUSER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('PAUSER_ROLE'),
);
const UPGRADER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('UPGRADER_ROLE'),
);

async function main() {
  const PlushSeed = await ethers.getContractFactory('PlushSeed');
  const plushSeed = await upgrades.deployProxy(PlushSeed, {
    kind: 'uups',
  });

  const signers = await ethers.getSigners();

  await plushSeed.deployed();
  console.log('PlushSeed -> deployed to address:', plushSeed.address);

  console.log('Grant all roles for DAO Protocol...\n');

  const grantAdminRole = await plushSeed.grantRole(
    constants.HashZero,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // ADMIN role

  await grantAdminRole.wait();

  const grantMinterRole = await plushSeed.grantRole(
    MINTER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // MINTER role

  await grantMinterRole.wait();

  const grantPauserRole = await plushSeed.grantRole(
    PAUSER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // PAUSER role

  await grantPauserRole.wait();

  const grantUpgraderRole = await plushSeed.grantRole(
    UPGRADER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // UPGRADER role

  await grantUpgraderRole.wait();

  console.log('Revoke all roles from existing account...\n');

  const revokeMinterRole = await plushSeed.revokeRole(
    MINTER_ROLE,
    await signers[0].getAddress(),
  ); // MINTER role

  await revokeMinterRole.wait();

  const revokePauserRole = await plushSeed.revokeRole(
    PAUSER_ROLE,
    await signers[0].getAddress(),
  ); // PAUSER role

  await revokePauserRole.wait();

  const revokeUpgraderRole = await plushSeed.revokeRole(
    UPGRADER_ROLE,
    await signers[0].getAddress(),
  ); // UPGRADER role

  await revokeUpgraderRole.wait();

  const revokeAdminRole = await plushSeed.revokeRole(
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

    await run('verify:verify', {
      address: await upgrades.erc1967.getImplementationAddress(
        plushSeed.address,
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
