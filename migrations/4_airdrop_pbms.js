const PBM = artifacts.require("PBM") ; 
const Spot = artifacts.require("Spot") ; 
const PBMAddr = artifacts.require("PBMAddressList") ; 

module.exports = async function (deployer,network, accounts) {

    const spot = await Spot.deployed() ; 
    const pbm = await PBM.deployed(); 
    const pbmAddr = await PBMAddr.deployed() ; 

    currentDate = new Date()
    currentEpoch = Math.floor(currentDate/1000) ; 
    var targetEpoch = currentEpoch+10000000;  // Expiry is set to 115 days, 17 hours, 46 minutes and 40 seconds

    await spot.mint(accounts[0], 100 ) ; 
    console.log("minted spot") ; 
    await pbm.createPBMTokenType("StraitsX", 5, targetEpoch, accounts[0], "https://gateway.pinata.cloud/ipfs/QmWZ4mWyvHPoKmnsTQmh76DX9G5T2kMq9KttQH7mp55P6a" ) ; 
    console.log("token type 5$ created") ; 
    await new Promise(r => setTimeout(r, 5000));
    await pbm.createPBMTokenType("StraitsX",10, targetEpoch, accounts[0], "https://gateway.pinata.cloud/ipfs/QmSyo8gFNhJ6J1t8R1QAWFi3mU8xGQkFKkAoncqAE5EEjV") ;
    console.log("token type 10$ created") ; 
    await new Promise(r => setTimeout(r, 5000));
    await spot.increaseAllowance(pbm.address, 100) ; 
    await new Promise(r => setTimeout(r, 5000));
    await pbm.batchMint([0,1], [5,5], accounts[0]) ; 
    console.log("pbms minted") ; 
}