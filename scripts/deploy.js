async function main() {
    // Grab the contract factory 
    const PlushCoreToken = await ethers.getContractFactory("PlushCoreToken");
    const PlushForestToken = await ethers.getContractFactory("PlushForestToken");
    const PlushLogo = await ethers.getContractFactory("PlushLogo");
    const PlushGetTree = await ethers.getContractFactory("PlushGetTree");
    const Plai = await ethers.getContractFactory("Plai");

    // Start deployment, returning a promise that resolves to a contract object
    // const plushCoreToken = await PlushCoreToken.deploy(); // Instance of the contract
    // console.log("Plush Core Token -> deployed to address:", plushCoreToken.address);

/*    const plushForestToken = await PlushForestToken.deploy(); // Instance of the contract
    console.log("Plush Forest Token -> deployed to address:", plushForestToken.address);*/

    //const plushLogo = await PlushLogo.deploy(); // Instance of the contract
    // console.log("Plush Logo -> deployed to address:", plushLogo.address);

    //const plai = await Plai.deploy(); // Instance of the contract
    //console.log("Plai -> deployed to address:", plai.address);

    const plushGetTree = await PlushGetTree.deploy(
        '0x252AD08aCCE18F7Ad0Cf73c82CD5440d57aAE2e8', // Forest address
        '0x7fd549d856c4a74fb902932dea896fa7de9d0823', // Plai address
        '0xdB38a0a93a9AE52d505bBd0E55aBB40aBdfaC8b5' // withdrawal address, need to change
    ); // Instance of the contract
    console.log("Plush GetTree -> hash:", plushGetTree.deployTransaction.hash);
    console.log("Plush GetTree -> deployed to address:", plushGetTree.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });