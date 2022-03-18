import { defender, ethers, upgrades } from 'hardhat';

async function main() {
  const proxyAddress = '0x8b25Bff08FDF1e1dCBA755C7BeECA6Ff233D5998'; // address with contract proxy
  const multisig = '0xBB8Fe52cAA5F35Ec1475ac2ac6f1A273D67E2a10'; // Gnosis safe address
  const title = 'Upgrade to new version'; // defender update title
  const description = 'Update baseURI link'; // defender update description

  const plushCoreTokenNewContract = await ethers.getContractFactory(
    'PlushCoreToken',
  );

  // await upgrades.forceImport(proxyAddress, plushForestNEW); // uncommit if there is no file in the local cache

  console.log('Preparing proposal...');

  const proposal = await defender.proposeUpgrade(
    proxyAddress,
    plushCoreTokenNewContract,
    {
      title: title,
      description: description,
      multisig: multisig,
    },
  );
  console.log('PlushCoreToken -> upgrade proposal created at:', proposal.url);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
