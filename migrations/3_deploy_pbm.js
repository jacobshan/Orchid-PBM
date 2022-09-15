const PBM = artifacts.require("PBM") ; 
const Spot = artifacts.require("Spot") ; 

module.exports = async function (deployer) {

    //currentDate = new Date()
    //currentEpoch = Math.floor(currentDate/1000) ; 
    //const expiryDate = currentEpoch + 200000; 
    const expiryDate = 1694683804;  

    const spot = await Spot.deployed() ; 
    // Polygon XSGD address = 0xDC3326e71D45186F113a2F448984CA0e8D201995 ; 
    await deployer.deploy(PBM, spot.address, expiryDate, "expiry_uri") ;     
}