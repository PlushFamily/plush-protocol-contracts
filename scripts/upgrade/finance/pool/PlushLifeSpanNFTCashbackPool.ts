import { defender, ethers, upgrades } from 'hardhat';

import { DevContractsAddresses } from '../../../../arguments/development/consts';

async function main() {
  const proxyAddress = DevContractsAddresses.PLUSH_NFT_CASHBACK_POOL; // address with contract proxy
  const multisig = DevContractsAddresses.PLUSH_DAO_PROTOCOL_ADDRESS; // Gnosis safe address
  const title = 'Upgrade to new version'; // defender update title
  const description = 'Update baseURI link'; // defender update description

  const plushLifeSpanNFTCashbackPool = await ethers.getContractFactory(
    'PlushLifeSpanNFTCashbackPool',
  );

  await upgrades.forceImport(proxyAddress, plushLifeSpanNFTCashbackPool);

  console.log('Preparing proposal...');

  const proposal = await defender.proposeUpgrade(
    proxyAddress,
    plushLifeSpanNFTCashbackPool,
    {
      title: title,
      description: description,
      multisig: multisig,
    },
  );
  console.log(
    'PlushLifeSpanNFTCashbackPool -> upgrade proposal created at:',
    proposal.url,
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
