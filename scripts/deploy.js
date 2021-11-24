async function main() {
    // Grab the contract factory 
    const PlushCoreToken = await ethers.getContractFactory("PlushCoreToken");
    const PlushForestToken = await ethers.getContractFactory("PlushForestToken");
    const PlushLogo = await ethers.getContractFactory("PlushLogo");
    const PlushGetTree = await ethers.getContractFactory("PlushGetTree");
    const PlushCoin = await ethers.getContractFactory("PlushCoin");

    // Start deployment, returning a promise that resolves to a contract object

/*    const plushCoreToken = await PlushCoreToken.deploy(); // Instance of the contract
    console.log("Plush Core Token -> deployed to address:", plushCoreToken.address);*/

/*    const plushForestToken = await PlushForestToken.deploy(); // Instance of the contract
    console.log("Plush Forest Token -> deployed to address:", plushForestToken.address);*/

    //const plushLogo = await PlushLogo.deploy(); // Instance of the contract
    // console.log("Plush Logo -> deployed to address:", plushLogo.address);

/*    const plush = await PlushCoin.deploy(); // Instance of the contract
    console.log("Plush Coin -> deployed to address:", plush.address);*/

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
    .catch(error => {
        console.error(error);
        process.exit(1);
    });