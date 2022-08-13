const PBM = artifacts.require("PBM") ; 
const Spot = artifacts. require("Spot") ; 


// contract ("PBM and Spot Set up test", () =>{
//     var spot = null ; 
//     var pbm = null ; 

//     before(async()=>{
//         spot = await Spot.deployed() ; 
//         pbm = await PBM.deployed() ; 
//     }) ; 

//     it ("Should deploy smart contract", async ()=> {
//         assert(pbm.address != "") ;
//         assert(spot.address != "") ;  
//     }); 
    
//     it ("Mint and Transfer Spot token to the PBM", async() => {
//         var pbm_spot = await pbm.spotToken.call() ; 
//         assert(spot.address==pbm_spot)
//     }) ; 

//     it ("Mint tokens to PBM and check balance", async() => {
//         await spot.mint(pbm.address, 10000) ; 
//         var balance = await spot.balanceOf(pbm.address) ; 
//         assert(balance.toString()=="10000")
//     }) ; 
// }) ; 

// contract ("Minting test for PBM", (accounts) =>{
    
//     var spot = null ; 
//     var pbm = null ; 

//     before(async()=>{
//         spot = await Spot.deployed() ; 
//         pbm = await PBM.deployed() ; 
//     }) ; 

//     it ("Minting before creating the token type gives an error", async ()=>{
//         try {
//             response = await pbm.mint(0, 1, accounts[0] ) ; 
//         }catch (e){
//             assert(e.reason=="Invalid token id(s)") ; 
//             return ; 
//         }
//         assert(false) ; 
//     }) ; 

//     it ("Correctly adds the token type", async () => {
//         currentDate = new Date()
//         currentEpoch = Math.floor(currentDate/1000) ; 
//         var targetEpoch = currentEpoch+100000;  // Expiry is set to 1 day 3.6 hours from current time
//         tokenId = await pbm.createTokenType("StraitsX", 20, targetEpoch ) ; 
//         assert(tokenId["logs"][0]["args"]['tokenId']==0) ; 
//         var tokenDetails = await pbm.getTokenDetails.call(0) ; 
//         assert(tokenDetails['0']=="StraitsX20") ; 
//         assert(tokenDetails['1'].toString()=="20") ; 
//         assert(tokenDetails['2'].toString()==targetEpoch) ; 
//         assert(tokenDetails['3']==accounts[0].toString()) ; 
//     }); 

//     it("Minting before funding the contract gives an error", async()=>{
//         try {
//             response = await pbm.mint(0, 1, accounts[0] ) ; 
//         }catch (e){
//             assert(e["reason"]=="Insufficient spot tokens") ; 
//             return ; 
//         }
//         assert(false) ;  
//     }) ; 

//     it ("Mint 20 tokens to PBM and check balance", async() => {
//         await spot.mint(pbm.address, 20) ; 
//         var balance = await spot.balanceOf(pbm.address) ; 
//         assert(balance.toString()=="20") ; 
//     }) ; 

//     it ("Minting more than the funded amount should give an error", async() => {
//         try {
//             response = await pbm.mint(0, 2, accounts[0] ) ; 
//         }catch (e){
//             assert(e["reason"]=="Insufficient spot tokens") ; 
//             return ; 
//         }
//         assert(false) ; 
//     }) ; 

//     it ("Only the owner of the contract should be allowed to mint", async()=>{
//         try {
//             response = await pbm.mint(0, 2, accounts[1], {from: accounts[1]} ) ; 
//         }catch (e){
//             assert(e["reason"]=="Ownable: caller is not the owner") ;  
//             return ; 
//         }
//         assert(false) ;  
//     }) ; 

//     it ("Add more funding and mint a PBM", async() => {
//         await spot.mint(pbm.address, 20) ; 
//         var balance = await spot.balanceOf(pbm.address) ; 
//         assert(balance.toString()=="40") ; 
        
//         // mint pbm
//         await pbm.mint(0,2, accounts[1]) ; 
//         var NFTbalance = await pbm.balanceOf.call(accounts[1], 0);
//         assert(NFTbalance.toString()=="2") ; 
//         var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
//         assert(NFTValueinPBM.toString()=="40") ; 
//     }) ; 

//     it ("Correct value of tokens is shown even during excess of spot funding", async()=>{
//         await spot.mint(pbm.address, 160) ; 
//         var balance = await spot.balanceOf(pbm.address) ; 
//         assert(balance.toString()=="200") ;
        
//         // mint pbms
//         await pbm.mint(0,3, accounts[2]) ; 
//         var NFTbalance = await pbm.balanceOf.call(accounts[2], 0);
//         assert(NFTbalance.toString()=="3") ; 
//         var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
//         assert(NFTValueinPBM.toString()=="100") ; 
//     })

// }) ; 

// // Unit tests to verify the Batch Mint of NFTs 
// contract("Batch Mint of NFTs", (accounts)=>{
//     var spot = null ; 
//     var pbm = null ; 

//     before(async()=>{
//         spot = await Spot.deployed() ; 
//         pbm = await PBM.deployed() ; 
//     }) ; 

//     it ("Minting before creating the token type gives an error", async ()=>{
//         try {
//             response = await pbm.mintBatch([0,1], [1,1], accounts[1]) ; 
//         }catch (e){
//             assert(e["reason"]=="Invalid token id(s)") ; 
//             return ; 
//         }
//         assert(false) ; 
//     }) ; 

//     it("Minting before funding with partially invalid addresses gives an error", async()=>{
//         // creating a token type 
//         currentDate = new Date()
//         currentEpoch = Math.floor(currentDate/1000) ; 
//         var targetEpoch = currentEpoch+100000;  // Expiry is set to 1 day 3.6 hours from current time
//         tokenId = await pbm.createTokenType("StraitsX", 20, targetEpoch ) ; 

//         // trying to mint the contract
//         try {
//             response = await pbm.mint([0,1], [1,1], accounts[0] ) ; 
//         }catch (e){
//             assert(e["reason"]=="Invalid token id(s)") ; 
//             return ; 
//         }
//         assert(false) ;  
//     }) ; 

//     it("Minting before funding the contract gives an error", async()=>{
//         // creating a token type 
//         currentDate = new Date()
//         currentEpoch = Math.floor(currentDate/1000) ; 
//         var targetEpoch = currentEpoch+100000;  // Expiry is set to 1 day 3.6 hours from current time
//         tokenId = await pbm.createTokenType("Xfers", 10, targetEpoch ) ; 

//         // trying to mint the contract
//         try {
//             response = await pbm.mint([0,1], [1,1], accounts[0] ) ; 
//         }catch (e){
//             assert(e["reason"]=="Insufficient spot tokens") ; 
//             return ; 
//         }
//         assert(false) ;  
//     }) ; 

//     it ("Mint 30 tokens to PBM and check balance", async() => {
//         await spot.mint(pbm.address, 30) ; 
//         var balance = await spot.balanceOf(pbm.address) ; 
//         assert(balance.toString()=="30") ; 
//     }) ; 

//     it ("Minting more than the funded amount should give an error", async() => {
//         try {
//             response = await pbm.mint([0,1], [1,2], accounts[1] ) ; 
//         }catch (e){
//             assert(e["reason"]=="Insufficient spot tokens") ; 
//             return ; 
//         }
//         assert(false) ; 
//     }) ; 

//     it ("Only the owner of the contract should be allowed to batch mint", async()=>{
//         try {
//             response = await pbm.mint([0,1], [1,1], accounts[1], {from: accounts[1]} ) ; 
//         }catch (e){
//             assert(e["reason"]=="Ownable: caller is not the owner") ;  
//             return ; 
//         }
//         assert(false) ;  
//     }) ; 

//     it ("Add more funding and mint a PBM", async() => {
//         await spot.mint(pbm.address, 20) ; 
//         var balance = await spot.balanceOf(pbm.address) ; 
//         assert(balance.toString()=="50") ; 
        
//         // mint pbm
//         await pbm.mintBatch([0,1],[1,3], accounts[1]) ; 
//         var NFTbalanceToken0 = await pbm.balanceOf.call(accounts[1], 0);
//         assert(NFTbalanceToken0.toString()=="1") ; 
//         var NFTbalanceToken0 = await pbm.balanceOf.call(accounts[1], 1);
//         assert(NFTbalanceToken0.toString()=="3") ; 
//         var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() ; 
//         assert(NFTValueinPBM.toString()=="50") ; 
//     }) ; 

//     it ("Correct value of tokens is shown even during excess of spot funding", async()=>{
//         await spot.mint(pbm.address, 150) ; 
//         var balance = await spot.balanceOf(pbm.address) ; 
//         assert(balance.toString()=="200") ;
        
//         // mint pbms
//         await pbm.mintBatch([0,1],[2,2], accounts[1]) ; 
//         var NFTbalanceToken0 = await pbm.balanceOf.call(accounts[1], 0);
//         assert(NFTbalanceToken0.toString()=="3") ; 
//         var NFTbalanceToken0 = await pbm.balanceOf.call(accounts[1], 1);
//         assert(NFTbalanceToken0.toString()=="5") ; 
//         var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
//         assert(NFTValueinPBM.toString()=="110") ; 
//     })
// }) ; 

// contract("Expiry of tokens and contract", ()=>{

// }) ; 

// contract("Transfer of PBM NFTs", (accounts)=>{
//     var spot = null ; 
//     var pbm = null ; 

//     before(async()=>{
//         spot = await Spot.deployed() ; 
//         pbm = await PBM.deployed() ; 
//     }) ;

//     after(async()=>{
//         var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
//         assert(NFTValueinPBM.toString()=="80") ; 
//     })

//     it("setting up the contract for transfer testing", async()=>{
//         // minting spot tokens into wallet 
//         await spot.mint(pbm.address, 1000) ;
//         // creating new token types
//         currentDate = new Date()
//         currentEpoch = Math.floor(currentDate/1000) ; 
//         var targetEpoch = currentEpoch+100000;  // Expiry is set to 1 day 3.6 hours from current time
//         await pbm.createTokenType("Xfers", 10, targetEpoch ) ; 
//         await pbm.createTokenType("StraitsX",20, targetEpoch) ; 
//         await pbm.createTokenType("Fazz",10, targetEpoch) ; 
//         await pbm.mintBatch([0,1,2],[2,2,2], accounts[1]) ;
//     })
     
//     it("Transfering tokens you don't own gives an error", async()=>{
//         try {
//             await pbm.safeTransferFrom(accounts[0], accounts[2], 0, 1, "0x") ;  
//         }catch (e){
//             assert(e["reason"]=="ERC1155: insufficient balance for transfer") ;  
//             var balance = await pbm.balanceOf.call(accounts[2],0)  ; 
//             assert(balance.toString()=="0") ; 
//             return ; 
//         }
//         assert(false) ;  
//     }); 

//     it("Batch Transfering tokens you don't own gives an error", async()=>{
//         try {
//             await pbm.safeBatchTransferFrom(accounts[0], accounts[2], [0,1], [1,0] , "0x") ;  
//         }catch (e){
//             assert(e["reason"]=="ERC1155: insufficient balance for transfer") ;  
//             var balance = await pbm.balanceOf.call(accounts[2],0)  ; 
//             assert(balance.toString()=="0") ; 
//             return ; 
//         }
//         assert(false) ;   
//     }); 

//     it("Transfering invalid token gives an error", async()=>{
//         try {
//             await pbm.safeTransferFrom(accounts[1], accounts[2], 3, 1, "0x", {from: accounts[1]}) ;  
//         }catch (e){
//             assert(e["reason"]=="Invalid token id(s)") ;  
//             var balance = await pbm.balanceOf.call(accounts[2],0)  ; 
//             assert(balance.toString()=="0") ; 
//             return ; 
//         }
//         assert(false) ; 
//     }); 

    
//     it("Batch transfering invalid tokens gives an error", async()=>{
//         try {
//             await pbm.safeBatchTransferFrom(accounts[1], accounts[2], [3,2], [1,0] , "0x", {from: accounts[1]}) ;  
//         }catch (e){
//             assert(e["reason"]=="Invalid token id(s)") ;  
//             var balance = await pbm.balanceOf.call(accounts[2],0)  ; 
//             assert(balance.toString()=="0") ; 
//             return ; 
//         }
//         assert(false) ;   
//     }); 

//     it("Valid Token Transfer", async()=>{
//         await pbm.safeTransferFrom(accounts[1], accounts[2], 0, 1, "0x", {from: accounts[1]}) ;
//         var account0Balance = await pbm.balanceOf.call(accounts[2],0) ; 
//         assert(account0Balance.toString()=="1") ; 
//         var account1Blanance = await pbm.balanceOf.call(accounts[1],0) ; 
//         assert(account1Blanance.toString()=="1"); 
//     }); 

//     it("Valid Batch Token Transfer", async()=>{
//         await pbm.safeBatchTransferFrom(accounts[1], accounts[3], [0,2], [1,2], "0x", {from: accounts[1]}) ;
//         var account3Token0Balance = await pbm.balanceOf.call(accounts[3],0) ; 
//         assert(account3Token0Balance.toString()=="1") ; 
//         var account3Token2Balance = await pbm.balanceOf.call(accounts[3],2) ; 
//         assert(account3Token2Balance.toString()=="2") ; 

//         var account1Token0Balance = await pbm.balanceOf.call(accounts[1],0) ; 
//         assert(account1Token0Balance.toString()=="0") ; 
//         var account1Token2Balance = await pbm.balanceOf.call(accounts[1],2) ; 
//         assert(account1Token2Balance.toString()=="0") ; 

//     }); 
// }) ; 

contract("Payment to whitelisted address through PBM NFTs", (accounts)=>{
    var spot = null ; 
    var pbm = null ; 

    before(async()=>{
        spot = await Spot.deployed() ; 
        pbm = await PBM.deployed() ; 
    }) ;

    it("Setting up the contract for transfer testing", async()=>{
        // minting spot tokens into wallet 
        await spot.mint(pbm.address, 1000) ;
        // creating new token types
        currentDate = new Date()
        currentEpoch = Math.floor(currentDate/1000) ; 
        var targetEpoch = currentEpoch+100000;  // Expiry is set to 1 day 3.6 hours from current time
        await pbm.createTokenType("Xfers", 10, targetEpoch ) ; 
        await pbm.createTokenType("StraitsX",20, targetEpoch) ; 
        await pbm.createTokenType("Fazz",10, targetEpoch) ; 
        await pbm.mintBatch([0,1,2],[2,2,2], accounts[1]) ;
    }); 

    it("Whitelisting merchant addresses", async()=>{
        await pbm.seedMerchantList([accounts[4], accounts[5]]) ; 
        var merchant0 = await pbm.merchantList.call(accounts[4]) ; 
        var merchant1 = await pbm.merchantList.call(accounts[5]) ; 
        assert(merchant0==true) ; 
        assert(merchant1==true) ; 
    }) ; 

    it("Valid payment transaction", async()=>{
        await pbm.safeTransferFrom(accounts[1], accounts[4], 1, 2, "0x", {from: accounts[1]}) ; 
        var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
        assert(NFTValueinPBM.toString()=="40") ; 
        var account1Token1Balance = await pbm.balanceOf(accounts[1],1) ; 
        assert(account1Token1Balance.toString()=="0") ; 
        var balance = await spot.balanceOf(accounts[4]) ; 
        assert(balance.toString()=="40")
    }) ; 

    it("Payment transaction using tokens you don't own", async()=>{
        try {
            await pbm.safeTransferFrom(accounts[1], accounts[5], 1, 2, "0x", {from: accounts[1]}) ;  
        }catch (e){
            assert(e["reason"]=="ERC1155: burn amount exceeds balance") ;  
            var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
            assert(NFTValueinPBM.toString()=="40") ; 
            return ; 
        }
        assert(false) ;  
    })

    it("Valid batch payment transaction", async()=>{
        await pbm.safeBatchTransferFrom(accounts[1], accounts[4], [0,2], [1,2], "0x", {from: accounts[1]}) ; 
        var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() ; 
        assert(NFTValueinPBM.toString()=="10") ; 
        var account1Token0Balance = await pbm.balanceOf(accounts[1],0) ; 
        assert(account1Token0Balance.toString()=="1") ;
        var account1Token2Balance = await pbm.balanceOf(accounts[1],2) ; 
        assert(account1Token2Balance.toString()=="0") ;  
        var balance = await spot.balanceOf(accounts[4]) ; 
        assert(balance.toString()=="70")
    }) ; 

    it("Batch payment transaction using tokens you don't own", async()=>{
        try {
            await pbm.safeBatchTransferFrom(accounts[1], accounts[5], [0,1], [1,2], "0x", {from: accounts[1]}) ;  
        }catch (e){
            console.log("error is ", e) ; 
            //assert(e["reason"]=="ERC1155: burn amount exceeds balance") ; 
            var account1Token0Balance = await pbm.balanceOf(accounts[1],0) ; 
            assert(account1Token0Balance.toString()=="1") ; 
            var NFTValueinPBM = await pbm.getSpotValueOfAllExistingTokens.call() 
            assert(NFTValueinPBM.toString()=="10") ; 
            return ; 
        }
        assert(false) ;  
    })
}) ; 

contract("Withdraw funds NFT", ()=>{

}) ; 

contract("Pausability of the smartcontract", ()=>{

}) ; 