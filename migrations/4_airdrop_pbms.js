const PBM = artifacts.require("PBM") ; 
const Spot = artifacts.require("Spot") ; 
const PBMAddr = artifacts.require("PBMAddressList") ; 

module.exports = async function (deployer,network, accounts) {

    // Migration to create and deploy PBM token types
    // Commented our since this is not required by all. UNCOMMENT and use as necessary

    // //const spot = await Spot.deployed() ; // UNCOMMENT  if you are using the ERC20 deployed in the second migration 
    // const pbm = await PBM.deployed(); 

    // // currentDate = new Date()
    // // currentEpoch = Math.floor(currentDate/1000) ; 
    // //var targetEpoch = currentEpoch+10000000;  // Expiry is set to 115 days, 17 hours, 46 minutes and 40 seconds
    // var targetEpoch = 1668070453; // november 11 is 1668070453


    // // Increasing allowance on deployed ERC20 tokens. UNCOMMENT below if you are using the ERC20 deployed in the second migration
    // //await spot.mint(accounts[0], 100 ) ; 
    // //console.log("minted spot") ; 

    // // creating new PBM token types
    // await pbm.createPBMTokenType("StraitsX", 10000, targetEpoch, accounts[0], "https://gateway.pinata.cloud/ipfs/QmXd8njnZTehRcVSNPvSwLguVUgMB5ySWM3qpRaUaXEU6D" ) ; 
    // console.log("PBM Token type 1 created") ; 
    // //await new Promise(r => setTimeout(r, 5000)); // UNCOMMENT to prevent rpc rate limiting if you are on free version

    // await pbm.createPBMTokenType("Grab",10000, targetEpoch, accounts[0], "https://gateway.pinata.cloud/ipfs/QmbGXCVgEHPCkJX81vceVdBH9gnKvja5aT3GWhNuwDbrHR") ;
    // console.log("PBM Token type 2 created") ; 
    // //await new Promise(r => setTimeout(r, 5000)); // UNCOMMENT to prevent rpc rate limiting if you are on free version

    // // Increasing allowance on deployed ERC20 tokens. UNCOMMENT below if you are using the ERC20 deployed in the second migration
    // //await spot.increaseAllowance(pbm.address, 100) ; 
    // //await new Promise(r => setTimeout(r, 5000)); // UNCOMMENT to prevent rpc rate limiting if you are on free version

    // await pbm.batchMint([0,1], [5,5], accounts[0]) ; 
    // console.log("PBM created and minted") ; 
}