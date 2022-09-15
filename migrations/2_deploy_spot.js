const Spot = artifacts.require("Spot") ; 

module.exports = async function (deployer) {
    deployer.deploy(Spot) ; 
}