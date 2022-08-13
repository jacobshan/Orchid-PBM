const PBM = artifacts.require("PBM") ; 
const Spot = artifacts. require("Spot") ; 


contract ("PBM and Spot Set up test", () =>{
    it ("Should deploy smart contract", async ()=> {
        const spot = await Spot.deployed() ; 
        const pbm = await PBM.deployed() ; 
        assert(pbm.address != "") ;
        assert(spot.address != "") ;  
    })
    
    it ("Mint and Transfer Spot token to the PBM", async() => {
        const spot = await Spot.deployed() ; 
        const pbm = await PBM.deployed() ; 
        var pbm_spot = await pbm.spotToken.call() ; 
        assert(spot.address==pbm_spot)
    }) ; 

    it ("Mint tokens to PBM and check balance", async() => {
        const spot = await Spot.deployed() ; 
        const pbm = await PBM.deployed() ; 
        await spot.mint(pbm.address, 10000) ; 
        var balance = await spot.balanceOf(pbm.address) ; 
        assert(balance["words"][0]==10000)
    }) ; 
}) ; 

contract ("Configuration test for PBM", () =>{
    it ("Correctly adds the token type", async () => {
        const pbm = await PBM.deployed() ; 

        currentDate = new Date()
        currentEpoch = Math.floor(currentDate/1000) ; 
        console.log("current epoch is : ", currentEpoch) ; 
        // await pbm.addTokenType("StraitsX", 20, 11234232321) ; 
        // var tokenName = await pbm.tokenNames.call(0) ; 
        // var tokenAmount = await pbm.tokenAmounts.call(0) ; 
        // assert(tokenAmount==20) ; 
        // assert(tokenName == "StraitsX-20$") ; 
    }); 
}) ; 