import { defender, ethers, upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../arguments/development/consts';

async function main() {
  const proxyAddress = DevContractsAddresses.PLUSH_GET_CORE_TOKEN_ADDRESS; // address with contract proxy
  const multisig = DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS; // Gnosis safe address
  const title = 'Upgrade to new version'; // defender update title
  const description = 'Update baseURI link'; // defender update description

  const plushGetCoreTokenNewContract = await ethers.getContractFactory(
    'PlushGetCoreToken',
  );

  await upgrades.forceImport(proxyAddress, plushGetCoreTokenNewContract);

  console.log('Preparing proposal...');

  const proposal = await defender.proposeUpgrade(
    proxyAddress,
    plushGetCoreTokenNewContract,
    {
      title: title,
      description: description,
      multisig: multisig,
    },
  );
  console.log(
    'PlushGetCoreToken -> upgrade proposal created at:',
    proposal.url,
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
