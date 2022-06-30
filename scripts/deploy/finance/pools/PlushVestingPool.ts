import { ethers, upgrades, run } from 'hardhat';
import { constants } from 'ethers';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

const OPERATOR_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('OPERATOR_ROLE'),
);
const UPGRADER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('UPGRADER_ROLE'),
);
const WITHDRAW_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('WITHDRAW_ROLE'),
);

async function main() {
  const PlushVestingPool = await ethers.getContractFactory('PlushVestingPool');

  const plushVestingPool = await upgrades.deployProxy(
    PlushVestingPool,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS,
      '10000', //Percent release at IDO (1000 = 1%)
      '15', //How many days will it be unlocked
    ],
    {
      kind: 'uups',
    },
  );

  const signers = await ethers.getSigners();
  await plushVestingPool.deployed();

  console.log(
    'PlushVestingPool -> deployed to address:',
    plushVestingPool.address,
  );

  console.log('Grant all roles for DAO Protocol...\n');

  const grantAdminRole = await plushVestingPool.grantRole(
    constants.HashZero,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // ADMIN role

  await grantAdminRole.wait();

  const grantOperatorRole = await plushVestingPool.grantRole(
    OPERATOR_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // MINTER role

  await grantOperatorRole.wait();

  const grantWithdrawRole = await plushVestingPool.grantRole(
    WITHDRAW_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // MINTER role

  await grantWithdrawRole.wait();

  const grantUpgraderRole = await plushVestingPool.grantRole(
    UPGRADER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // UPGRADER role

  await grantUpgraderRole.wait();

  console.log('Revoke all roles from existing account...\n');

  const revokeWithdrawRole = await plushVestingPool.revokeRole(
    WITHDRAW_ROLE,
    await signers[0].getAddress(),
  ); // MINTER role

  await revokeWithdrawRole.wait();

  const revokeOperatorRole = await plushVestingPool.revokeRole(
    OPERATOR_ROLE,
    await signers[0].getAddress(),
  ); // MINTER role

  await revokeOperatorRole.wait();

  const revokeUpgraderRole = await plushVestingPool.revokeRole(
    UPGRADER_ROLE,
    await signers[0].getAddress(),
  ); // UPGRADER role

  await revokeUpgraderRole.wait();

  const revokeAdminRole = await plushVestingPool.revokeRole(
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
        plushVestingPool.address,
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
