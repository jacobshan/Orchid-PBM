const PBM = artifacts.require("PBM") ; 
const Spot = artifacts. require("Spot") ; 


contract ("PBM and Spot Set up test", () =>{
    var spot = null ; 
    var pbm = null ; 

    before(async()=>{
        spot = await Spot.deployed() ; 
        pbm = await PBM.deployed() ; 
    }) ; 

    it ("Should deploy smart contract", async ()=> {
        assert(pbm.address != "") ;
        assert(spot.address != "") ;  
    }); 
    
    it ("Mint and Transfer Spot token to the PBM", async() => {
        var pbm_spot = await pbm.spotToken.call() ; 
        assert(spot.address==pbm_spot)
    }) ; 

    it ("Mint tokens to PBM and check balance", async() => {
        await spot.mint(pbm.address, 10000) ; 
        var balance = await spot.balanceOf(pbm.address) ; 
        assert(balance.toString()=="10000")
    }) ; 
}) ; 

contract ("Minting test for PBM", (accounts) =>{
    
    var spot = null ; 
    var pbm = null ; 

    before(async()=>{
        spot = await Spot.deployed() ; 
        pbm = await PBM.deployed() ; 
    }) ; 

    it ("Minting before creating the token type gives an error", async ()=>{
        try {
            response = await pbm.mint(0, 1, accounts[0] ) ; 
        }catch (e){
            assert(e.reason=="The token id is invalid, please create a new token type or use an existing one") ; 
            return ; 
        }
        assert(false) ; 
    }) ; 

    it ("Correctly adds the token type", async () => {
        currentDate = new Date()
        currentEpoch = Math.floor(currentDate/1000) ; 
        var targetEpoch = currentEpoch+100000;  // Expiry is set to 1 day 3.6 hours from current time
        tokenId = await pbm.createTokenType("StraitsX", 20, targetEpoch ) ; 
        assert(tokenId["logs"][0]["args"]['tokenId']==0) ; 
        var tokenDetails = await pbm.getTokenDetails.call(0) ; 
        assert(tokenDetails['0']=="StraitsX20") ; 
        assert(tokenDetails['1'].toString()=="20") ; 
        assert(tokenDetails['2'].toString()==targetEpoch) ; 
        assert(tokenDetails['3']==accounts[0].toString()) ; 
    }); 

    it("Minting before funding the contract gives an error", async()=>{
        try {
            response = await pbm.mint(0, 1, accounts[0] ) ; 
        }catch (e){
            assert(e["reason"]=="The contract does not have the necessary spot to support the mint of the new tokens") ; 
            return ; 
        }
        assert(false) ;  
    }) ; 

    it ("Mint 20 tokens to PBM and check balance", async() => {
        await spot.mint(pbm.address, 20) ; 
        var balance = await spot.balanceOf(pbm.address) ; 
        assert(balance.toString()=="20") ; 
    }) ; 

    it ("Minting more than the funded amount should give an error", async() => {
        try {
            response = await pbm.mint(0, 2, accounts[0] ) ; 
        }catch (e){
            assert(e["reason"]=="The contract does not have the necessary spot to support the mint of the new tokens") ; 
            return ; 
        }
        assert(false) ; 
    }) ; 

    it ("Only the owner of the contract should be allowed to mint", async()=>{
        try {
            response = await pbm.mint(0, 2, accounts[1], {from: accounts[1]} ) ; 
        }catch (e){
            assert(e["reason"]=="Ownable: caller is not the owner") ;  
            return ; 
        }
        assert(false) ;  
    }) ; 

    it ("Add more funding and mint a PBM", async() => {
        await spot.mint(pbm.address, 20) ; 
        var balance = await spot.balanceOf(pbm.address) ; 
        assert(balance.toString()=="40") ; 
        
        // mint pbm
        await pbm.mint(0,2, accounts[1]) ; 
        var NFTbalance = await pbm.balanceOf.call(accounts[1], 0);
        assert(NFTbalance.toString()=="2") ; 
        var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
        assert(NFTValueinPBM.toString()=="40") ; 
    }) ; 

    it ("Correct value of tokens is shown even during excess of spot funding", async()=>{
        await spot.mint(pbm.address, 160) ; 
        var balance = await spot.balanceOf(pbm.address) ; 
        assert(balance.toString()=="200") ;
        
        // mint pbms
        await pbm.mint(0,3, accounts[2]) ; 
        var NFTbalance = await pbm.balanceOf.call(accounts[2], 0);
        assert(NFTbalance.toString()=="3") ; 
        var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
        assert(NFTValueinPBM.toString()=="100") ; 
    })

}) ; 

// Unit tests to verify the Batch Mint of NFTs 
contract("Batch Mint of NFTs", (accounts)=>{
    var spot = null ; 
    var pbm = null ; 

    before(async()=>{
        spot = await Spot.deployed() ; 
        pbm = await PBM.deployed() ; 
    }) ; 

    it ("Minting before creating the token type gives an error", async ()=>{
        try {
            response = await pbm.mintBatch([0,1], [1,1], accounts[1]) ; 
        }catch (e){
            assert(e["reason"]=="The token id is invalid, please create a new token type or use an existing one") ; 
            return ; 
        }
        assert(false) ; 
    }) ; 

    it("Minting before funding with partially invalid addresses gives an error", async()=>{
        // creating a token type 
        currentDate = new Date()
        currentEpoch = Math.floor(currentDate/1000) ; 
        var targetEpoch = currentEpoch+100000;  // Expiry is set to 1 day 3.6 hours from current time
        tokenId = await pbm.createTokenType("StraitsX", 20, targetEpoch ) ; 

        // trying to mint the contract
        try {
            response = await pbm.mint([0,1], [1,1], accounts[0] ) ; 
        }catch (e){
            assert(e["reason"]=="The token id is invalid, please create a new token type or use an existing one") ; 
            return ; 
        }
        assert(false) ;  
    }) ; 

    it("Minting before funding the contract gives an error", async()=>{
        // creating a token type 
        currentDate = new Date()
        currentEpoch = Math.floor(currentDate/1000) ; 
        var targetEpoch = currentEpoch+100000;  // Expiry is set to 1 day 3.6 hours from current time
        tokenId = await pbm.createTokenType("Xfers", 10, targetEpoch ) ; 

        // trying to mint the contract
        try {
            response = await pbm.mint([0,1], [1,1], accounts[0] ) ; 
        }catch (e){
            assert(e["reason"]=="The contract does not have the necessary spot to support the mint of the new tokens") ; 
            return ; 
        }
        assert(false) ;  
    }) ; 

    it ("Mint 30 tokens to PBM and check balance", async() => {
        await spot.mint(pbm.address, 30) ; 
        var balance = await spot.balanceOf(pbm.address) ; 
        assert(balance.toString()=="30") ; 
    }) ; 

    it ("Minting more than the funded amount should give an error", async() => {
        try {
            response = await pbm.mint([0,1], [1,2], accounts[1] ) ; 
        }catch (e){
            assert(e["reason"]=="The contract does not have the necessary spot to support the mint of the new tokens") ; 
            return ; 
        }
        assert(false) ; 
    }) ; 

    it ("Only the owner of the contract should be allowed to batch mint", async()=>{
        try {
            response = await pbm.mint([0,1], [1,1], accounts[1], {from: accounts[1]} ) ; 
        }catch (e){
            assert(e["reason"]=="Ownable: caller is not the owner") ;  
            return ; 
        }
        assert(false) ;  
    }) ; 

    it ("Add more funding and mint a PBM", async() => {
        await spot.mint(pbm.address, 20) ; 
        var balance = await spot.balanceOf(pbm.address) ; 
        assert(balance.toString()=="50") ; 
        
        // mint pbm
        await pbm.mintBatch([0,1],[1,3], accounts[1]) ; 
        var NFTbalanceToken0 = await pbm.balanceOf.call(accounts[1], 0);
        assert(NFTbalanceToken0.toString()=="1") ; 
        var NFTbalanceToken0 = await pbm.balanceOf.call(accounts[1], 1);
        assert(NFTbalanceToken0.toString()=="3") ; 
        var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() ; 
        assert(NFTValueinPBM.toString()=="50") ; 
    }) ; 

    it ("Correct value of tokens is shown even during excess of spot funding", async()=>{
        await spot.mint(pbm.address, 150) ; 
        var balance = await spot.balanceOf(pbm.address) ; 
        assert(balance.toString()=="200") ;
        
        // mint pbms
        await pbm.mintBatch([0,1],[2,2], accounts[1]) ; 
        var NFTbalanceToken0 = await pbm.balanceOf.call(accounts[1], 0);
        assert(NFTbalanceToken0.toString()=="3") ; 
        var NFTbalanceToken0 = await pbm.balanceOf.call(accounts[1], 1);
        assert(NFTbalanceToken0.toString()=="5") ; 
        var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
        assert(NFTValueinPBM.toString()=="110") ; 
    })
}) ; 

contract("Expiry of tokens and contract", ()=>{

}) ; 

contract("Transfer of PBM NFTs", ()=>{

}) ; 

contract("Batch Transfer of PBM NFTs", ()=>{

}) ; 

contract("Payment to whitelisted address through PBM NFTs", ()=>{

}) ; 

contract("Withdraw funds NFT", ()=>{

}) ; 