const PBM = artifacts.require("PBM") ; 
const Spot = artifacts.require("Spot") ; 
const PBMAddr = artifacts.require("PBMAddressList") ; 

module.exports = async function (deployer) {

    // deploying PBM addr
    await deployer.deploy(PBMAddr) ; 
    const pbmAddr = await PBMAddr.deployed(); 


    const expiryDate = 1694683804;  
    // if you'd prefer to set an expiry a few days from now, UNCOMMENT the code below, and comment the above line.
    /*
    ** currentDate = new Date()
    ** currentEpoch = Math.floor(currentDate/1000) ; 
    ** const expiryDate = currentEpoch + 200000; 
    */
    await deployer.deploy(PBM, "expiry_uri") ; 
    pbm = await PBM.deployed(); 

    const spot = await Spot.deployed() ; 
    const address = spot.address; 
    // If you are deploying to a public testnet/mainnet , and want to use an existing ERC-20 contract, COMMENT OUT the lines above, and UNCOMMENT the code below
    // const address = 0xDC3326e71D45186F113a2F448984CA0e8D201995 ;     // Polygon XSGD address 
    await pbm.initialise(address, expiryDate, pbmAddr.address);    
}