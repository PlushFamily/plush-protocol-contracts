import { defender, ethers, upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const proxyAddress = DevContractsAddresses.PLUSH_COIN_WALLETS_ADDRESS; // address with contract proxy
  const multisig = DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS; // Gnosis safe address
  const title = 'Upgrade to new version'; // defender update title
  const description = 'Update baseURI link'; // defender update description

  const plushCoinWalletsNewContract = await ethers.getContractFactory(
    'PlushCoinWallets',
  );

  await upgrades.forceImport(proxyAddress, plushCoinWalletsNewContract);

  console.log('Preparing proposal...');

  const proposal = await defender.proposeUpgrade(
    proxyAddress,
    plushCoinWalletsNewContract,
    {
      title: title,
      description: description,
      multisig: multisig,
    },
  );
  console.log('PlushCoinWallets -> upgrade proposal created at:', proposal.url);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
