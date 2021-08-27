async function main() {
    // Grab the contract factory 
    const PlushCoreToken = await ethers.getContractFactory("PlushCoreToken");
    const PlushForestToken = await ethers.getContractFactory("PlushForestToken");
    const PlushLogo = await ethers.getContractFactory("PlushLogo");
    
    // Start deployment, returning a promise that resolves to a contract object
    const plushCoreToken = await PlushCoreToken.deploy(); // Instance of the contract
    console.log("Plush Core Token -> deployed to address:", plushCoreToken.address);

    const plushForestToken = await PlushForestToken.deploy(); // Instance of the contract
    console.log("Plush Forest Token -> deployed to address:", plushForestToken.address);

    const plushLogo = await PlushLogo.deploy(); // Instance of the contract
    console.log("Plush Logo -> deployed to address:", plushLogo.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });