const PBM = artifacts.require("PBM") ; 
const PBMAddr = artifacts.require("PBMAddressList") ; 
const PBMTokenManager = artifacts.require("PBMTokenManager") ; 

module.exports = async (deployer, network, accounts) => {
    
    pbm = await PBM.deployed() ; 
    pbmAddr = await PBMAddr.deployed() ; 
    pbmTokenManager = await PBMTokenManager.deployed() ; 

    // Print ADDRESSES of deployed contracts
    console.log();
    console.log(`   Contract Addresses`);
    console.log('   ------------------------');
    console.log(`   ${"> PBM:".padEnd(23, " ")} ${pbm.address}`);
    console.log(`   ${"> PBMAddrList:".padEnd(23, " ")} ${pbmAddr.address}`);
    console.log(`   ${"> PBMTokenManager:".padEnd(23, " ")} ${pbmTokenManager.address}`);
    console.log(`   ${"> Spot:".padEnd(23, " ")} ${await pbm.spotToken.call()}`);
    console.log();
};