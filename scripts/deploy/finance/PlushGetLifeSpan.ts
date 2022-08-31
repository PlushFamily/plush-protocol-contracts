import hre, { ethers, upgrades } from 'hardhat';
import { constants } from 'ethers';

import { DevContractsAddresses } from '../../../arguments/development/consts';

const BANKER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('BANKER_ROLE'),
);

const STAFF_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('STAFF_ROLE'),
);

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
  const PlushGetLifeSpan = await hre.ethers.getContractFactory(
    'PlushGetLifeSpan',
  );

  const signers = await ethers.getSigners();

  const plushGetLifeSpan = await upgrades.deployProxy(
    PlushGetLifeSpan,
    [
      DevContractsAddresses.LIFESPAN_ADDRESS,
      DevContractsAddresses.PLUSH_NFT_CASHBACK_POOL_ADDRESS,
      DevContractsAddresses.PLUSH_FEE_COLLECTOR_ADDRESS,
      ethers.utils.parseUnits('0.001', 18),
    ],
    {
      kind: 'uups',
    },
  );

  await plushGetLifeSpan.deployed();
  console.log(
    'PlushGetLifeSpan -> deployed to address:',
    plushGetLifeSpan.address,
  );

  console.log('Grant all roles for DAO Protocol...\n');

  const grantAdminRole = await plushGetLifeSpan.grantRole(
    constants.HashZero,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // ADMIN role

  await grantAdminRole.wait();

  const grantBankerRole = await plushGetLifeSpan.grantRole(
    BANKER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  );

  await grantBankerRole.wait();

  await grantAdminRole.wait();

  const grantStaffRole = await plushGetLifeSpan.grantRole(
    STAFF_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  );

  await grantStaffRole.wait();

  const grantOperatorRole = await plushGetLifeSpan.grantRole(
    OPERATOR_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // OPERATOR role

  await grantOperatorRole.wait();

  const grantPauserRole = await plushGetLifeSpan.grantRole(
    PAUSER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // PAUSER role

  await grantPauserRole.wait();

  const grantUpgraderRole = await plushGetLifeSpan.grantRole(
    UPGRADER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // UPGRADER role

  await grantUpgraderRole.wait();

  console.log('Revoke all roles from existing account...\n');

  const revokeBankerRole = await plushGetLifeSpan.revokeRole(
    BANKER_ROLE,
    await signers[0].getAddress(),
  );

  await revokeBankerRole.wait();

  const revokeStaffRole = await plushGetLifeSpan.revokeRole(
    STAFF_ROLE,
    await signers[0].getAddress(),
  );

  await revokeStaffRole.wait();

  const revokeOperatorRole = await plushGetLifeSpan.revokeRole(
    OPERATOR_ROLE,
    await signers[0].getAddress(),
  ); // OPERATOR role

  await revokeOperatorRole.wait();

  const revokeUpgraderRole = await plushGetLifeSpan.revokeRole(
    UPGRADER_ROLE,
    await signers[0].getAddress(),
  ); // UPGRADER role

  await revokeUpgraderRole.wait();

  const revokePauserRole = await plushGetLifeSpan.revokeRole(
    PAUSER_ROLE,
    await signers[0].getAddress(),
  ); // PAUSER role

  await revokePauserRole.wait();

  const revokeAdminRole = await plushGetLifeSpan.revokeRole(
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
        plushGetLifeSpan.address,
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
