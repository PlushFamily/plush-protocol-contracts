import { ethers, upgrades, run } from 'hardhat';
import { constants } from 'ethers';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

const OPERATOR_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('OPERATOR_ROLE'),
);
const UPGRADER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('UPGRADER_ROLE'),
);

async function main() {
  const PlushVestingSeedInvestorsPool = await ethers.getContractFactory(
    'PlushVestingSeedInvestorsPool',
  );

  const plushVestingSeedInvestorsPool = await upgrades.deployProxy(
    PlushVestingSeedInvestorsPool,
    [
      DevContractsAddresses.PLUSH_COIN_ADDRESS, //plushCoin
      DevContractsAddresses.PLUSH_SEED, //PlushSeed ERC721
      DevContractsAddresses.PLUSH_SEED_TOKENS_KEEPER, //PlushSeed Keeper
      0, //id PlushSeed ERC721
      '10000', //Percent release at IDO (1000 = 1%)
      '450', //How many days will it be unlocked
    ],
    {
      kind: 'uups',
    },
  );

  const signers = await ethers.getSigners();
  await plushVestingSeedInvestorsPool.deployed();

  console.log(
    'PlushVestingSeedInvestorsPool -> deployed to address:',
    plushVestingSeedInvestorsPool.address,
  );

  console.log('Grant all roles for DAO Protocol...\n');

  const grantAdminRole = await plushVestingSeedInvestorsPool.grantRole(
    constants.HashZero,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // ADMIN role

  await grantAdminRole.wait();

  const grantOperatorRole = await plushVestingSeedInvestorsPool.grantRole(
    OPERATOR_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // MINTER role

  await grantOperatorRole.wait();

  const grantUpgraderRole = await plushVestingSeedInvestorsPool.grantRole(
    UPGRADER_ROLE,
    DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS,
  ); // UPGRADER role

  await grantUpgraderRole.wait();

  console.log('Revoke all roles from existing account...\n');

  const revokeOperatorRole = await plushVestingSeedInvestorsPool.revokeRole(
    OPERATOR_ROLE,
    await signers[0].getAddress(),
  ); // MINTER role

  await revokeOperatorRole.wait();

  const revokeUpgraderRole = await plushVestingSeedInvestorsPool.revokeRole(
    UPGRADER_ROLE,
    await signers[0].getAddress(),
  ); // UPGRADER role

  await revokeUpgraderRole.wait();

  const revokeAdminRole = await plushVestingSeedInvestorsPool.revokeRole(
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
        plushVestingSeedInvestorsPool.address,
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
