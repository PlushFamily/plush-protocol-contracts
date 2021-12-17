import { ethers } from 'hardhat';

async function main() {
  // Grab the contract factory
  /*    const PlushCoreToken = await ethers.getContractFactory("PlushCoreToken");
    const PlushForest = await ethers.getContractFactory("PlushForest");
    const PlushLogo = await ethers.getContractFactory("PlushLogo");
    const PlushGetTree = await ethers.getContractFactory("PlushGetTree");
    const PlushCoin = await ethers.getContractFactory("PlushCoin");*/
  const PlushChild = await ethers.getContractFactory('PlushChild');

  // Start deployment, returning a promise that resolves to a contract object

  /*    const plushCoreToken = await PlushCoreToken.deploy(); // Instance of the contract
    console.log("Plush Core Token -> deployed to address:", plushCoreToken.address);*/

  /*    const plushForest = await PlushForest.deploy(); // Instance of the contract
    console.log("Plush Forest -> deployed to address:", plushForest.address);*/

  //const plushLogo = await PlushLogo.deploy(); // Instance of the contract
  // console.log("Plush Logo -> deployed to address:", plushLogo.address);

  /*    const plush = await PlushCoin.deploy(); // Instance of the contract
    console.log("Plush Coin -> deployed to address:", plush.address);*/

  const plushChild = await PlushChild.deploy(
    'PlushCoin',
    'PLAI',
    18,
    '0xb5505a6d998549090530911180f38aC5130101c6',
  ); // Instance of the contract
  console.log('Plush Coin Child -> deployed to address:', plushChild.address);

  /*    const plushGetTree = await PlushGetTree.deploy(
        '0xd5015643F38A06b2962283Ec0B9fF555812Adcd0', // Forest address
        '0x8663f80619Cbc4562FF8e0986917429E917C79ba', // Plush Coin address
        '0x5d367Ba836ce0C90E9fd3D58E0A7aCb6f63Dc7b1' // withdrawal address, need to change
    ); // Instance of the contract
    console.log("Plush GetTree -> hash:", plushGetTree.deployTransaction.hash);
    console.log("Plush GetTree -> deployed to address:", plushGetTree.address);*/
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
