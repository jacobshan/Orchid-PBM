const Spot = artifacts.require("Spot") ; 
const PBM = artifacts.require("PBM") ;

module.exports = async function (deployer) {
    deployer.deploy(Spot) ; 
    deployer.deploy(PBM)
}