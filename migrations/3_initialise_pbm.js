const PBM = artifacts.require("PBM") ; 
const Spot = artifacts.require("Spot") ; 

module.exports = async function (deployer) {

    const spot = await Spot.deployed() ; 
    const pbm = await PBM.deployed() ; 
    currentDate = new Date()
    currentEpoch = Math.floor(currentDate/1000) ; 
    // Polygon XSGD address = 0xDC3326e71D45186F113a2F448984CA0e8D201995 ; 
    await pbm.initialise(spot.address , currentEpoch + 200000) ; // contract expiry is set to 2 days and 7 hours from now for testing
    
}