const PBM = artifacts.require("PBM") ; 
const Spot = artifacts.require("Spot") ; 
const PBMAddr = artifacts.require("PBMAddressList") ; 

module.exports = async function (deployer,network, accounts) {

    // //const spot = await Spot.deployed() ; 
    // const pbm = await PBM.deployed(); 
    // //const pbmAddr = await PBMAddr.deployed() ; 

    // currentDate = new Date()
    // currentEpoch = Math.floor(currentDate/1000) ; 
    // //var targetEpoch = currentEpoch+10000000;  // Expiry is set to 115 days, 17 hours, 46 minutes and 40 seconds
    // var targetEpoch = 1668070453; // november 11 is 1668070453
    // //await spot.mint(accounts[0], 100 ) ; 
    // //console.log("minted spot") ; 
    // await pbm.createPBMTokenType("StraitsX", 10000, targetEpoch, accounts[0], "https://gateway.pinata.cloud/ipfs/QmXd8njnZTehRcVSNPvSwLguVUgMB5ySWM3qpRaUaXEU6D" ) ; 
    // console.log("token type 5$ created") ; 
    // await new Promise(r => setTimeout(r, 5000));
    // await pbm.createPBMTokenType("Grab",10000, targetEpoch, accounts[0], "https://gateway.pinata.cloud/ipfs/QmbGXCVgEHPCkJX81vceVdBH9gnKvja5aT3GWhNuwDbrHR") ;
    // console.log("token type 10$ created") ; 
    // await new Promise(r => setTimeout(r, 5000));
    // // manually increasea allowance
    // //await spot.increaseAllowance(pbm.address, 100) ; 
    // await new Promise(r => setTimeout(r, 5000));
    // await pbm.batchMint([0,1], [5,5], accounts[0]) ; 
    // console.log("pbms minted") ; 
}