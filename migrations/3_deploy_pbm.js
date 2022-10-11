const PBM = artifacts.require("PBM") ; 
const Spot = artifacts.require("Spot") ; 
const PBMAddr = artifacts.require("PBMAddressList") ; 
const PBMTokenManager = artifacts.require("PBMTokenManager")

module.exports = async function (deployer) {

    // deploying PBM addr
    await deployer.deploy(PBMAddr) ; 
    const pbmAddr = await PBMAddr.deployed(); 
    await new Promise(r => setTimeout(r, 5000));
    console.log("Pbm address manager is : ", pbmAddr.address) ; 


    const expiryDate = 1668070455; // Nov 11, 2022
    // if you'd prefer to set an expiry a few days from now, UNCOMMENT the code below, and comment the above line.
    /*
    ** currentDate = new Date()
    ** currentEpoch = Math.floor(currentDate/1000) ; 
    ** const expiryDate = currentEpoch + 200000; 
    */
    await deployer.deploy(PBM) ; 
    pbm = await PBM.deployed(); 
    await new Promise(r => setTimeout(r, 5000));
    console.log("pbm addresss  : ", pbm.address)

    //const spot = await Spot.deployed() ; 
    //const address = spot.address; 
    // If you are deploying to a public testnet/mainnet , and want to use an existing ERC-20 contract, COMMENT OUT the lines above, and UNCOMMENT the code below
    const address = "0xDC3326e71D45186F113a2F448984CA0e8D201995" ;     // Polygon XSGD address 

    await deployer.deploy(PBMTokenManager) ; 
    const pbmTokenManager = await PBMTokenManager.deployed() ; 
    await pbmTokenManager.transferOwnership(pbm); 
    await new Promise(r => setTimeout(r, 5000));


    await pbm.initialise(address, expiryDate, pbmAddr.address, pbmTokenManager.address);    
    await new Promise(r => setTimeout(r, 5000));
}