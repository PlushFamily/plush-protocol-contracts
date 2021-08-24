async function main() {
    // Grab the contract factory 
    const PlushCoreToken = await ethers.getContractFactory("PlushCoreToken");
    const PlushForestToken = await ethers.getContractFactory("PlushForestToken");
    
    // Start deployment, returning a promise that resolves to a contract object
    const plushCoreToken = await PlushCoreToken.deploy(); // Instance of the contract 
    console.log("Contract deployed to address:", plushCoreToken.address);

    const plushForestToken = await PlushForestToken.deploy(); // Instance of the contract
    console.log("Contract deployed to address:", plushForestToken.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });