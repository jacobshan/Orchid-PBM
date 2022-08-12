const PBM = artifacts.require("PBM") ; 
const Spot = artifacts.require("Spot") ; 

module.exports = async function (deployer) {

    const spot = await Spot.deployed() ; 
    const pbm = await PBM.deployed() ; 

    await pbm.initialise(spot.address , 12345)

    // // Polygon XSGD address = 0xDC3326e71D45186F113a2F448984CA0e8D201995 
    // console.log(spot.address) ; 
    // // to be used while testing
    // deployer.deploy(PBM, "0xDC3326e71D45186F113a2F448984CA0e8D201995" ) ; 
}