import { defender, ethers, upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const proxyAddress = DevContractsAddresses.LIFESPAN_ADDRESS; // address with contract proxy
  const multisig = DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS; // Gnosis safe address
  const title = 'Upgrade to new version'; // defender update title
  const description = 'Update baseURI link'; // defender update description

  const lifeSpanNewContract = await ethers.getContractFactory('LifeSpan');

  await upgrades.forceImport(proxyAddress, lifeSpanNewContract);

  console.log('Preparing proposal...');

  const proposal = await defender.proposeUpgrade(
    proxyAddress,
    lifeSpanNewContract,
    {
      title: title,
      description: description,
      multisig: multisig,
    },
  );
  console.log('LifeSpan -> upgrade proposal created at:', proposal.url);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
