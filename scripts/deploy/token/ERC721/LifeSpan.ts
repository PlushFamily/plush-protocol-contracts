import { ethers, upgrades, run } from 'hardhat';
import { constants } from 'ethers';

import { DevContractsAddresses } from '../../../../arguments/development/consts';
import { DevLinks } from '../../../../arguments/development/consts';

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
  const LifeSpan = await ethers.getContractFactory('LifeSpan');
  const lifeSpan = await upgrades.deployProxy(
    LifeSpan,
    [
      DevLinks.PLUSH_LIFESPAN_CONTRACT_URI,
      DevLinks.PLUSH_LIFESPAN_EXTERNAL_LINK,
      DevLinks.PLUSH_GENERATOR_IMG_LIFESPAN_LINK,
    ],
    {
      kind: 'uups',
    },
  );

  const signers = await ethers.getSigners();

  await lifeSpan.deployed();
  console.log('LifeSpan -> deployed to address:', lifeSpan.address);

  console.log('Add genders...\n');

  const male = await lifeSpan.addGender(0, 'MALE'); // MALE gender
  await male.wait();

  const female = await lifeSpan.addGender(1, 'FEMALE'); // FEMALE gender
  await female.wait();

  console.log('Grant all roles for DAO Protocol...\n');

  const grantAdminRole = await lifeSpan.grantRole(
    constants.HashZero,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // ADMIN role

  await grantAdminRole.wait();

  const grantMinterRole = await lifeSpan.grantRole(
    MINTER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // MINTER role

  await grantMinterRole.wait();

  const grantPauserRole = await lifeSpan.grantRole(
    PAUSER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // PAUSER role

  await grantPauserRole.wait();

  const grantUpgraderRole = await lifeSpan.grantRole(
    UPGRADER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // UPGRADER role

  await grantUpgraderRole.wait();

  console.log('Revoke all roles from existing account...\n');

  const revokeMinterRole = await lifeSpan.revokeRole(
    MINTER_ROLE,
    await signers[0].getAddress(),
  ); // MINTER role

  await revokeMinterRole.wait();

  const revokePauserRole = await lifeSpan.revokeRole(
    PAUSER_ROLE,
    await signers[0].getAddress(),
  ); // PAUSER role

  await revokePauserRole.wait();

  const revokeUpgraderRole = await lifeSpan.revokeRole(
    UPGRADER_ROLE,
    await signers[0].getAddress(),
  ); // UPGRADER role

  await revokeUpgraderRole.wait();

  const revokeAdminRole = await lifeSpan.revokeRole(
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
