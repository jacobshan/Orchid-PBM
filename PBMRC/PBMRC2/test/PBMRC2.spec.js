const { assert, expect } = require('chai');
const { ethers} = require("hardhat");
async function deploy(name, ...params) {
    const Contract = await ethers.getContractFactory(name);
    return await Contract.deploy(...params).then(f => f.deployed());
}

describe("PBMRC2", async () => {
    const accounts = [];
    let SpotFactory;
    let PBMRC2Factory;

    before(async ()=>{
        (await ethers.getSigners()).forEach((signer,index) => {
            accounts[index] = signer;
        });
    });

    async function init() {
        let spot = await deploy("Spot");
        let pbmrc2 = await deploy("PBMRC2");
        let addressList = await deploy("PBMAddressList");
        await pbmrc2.initialise(spot.address, Math.round(new Date().getTime() / 1000 + 86400 * 30), addressList.address);
        return [spot, pbmrc2];
    }


    describe("PBMRC2 and Spot Set up test", async () => {
        let spot;
        let pbmrc2;

        before(async () => {
            let [_spot, _pbmrc2] = await init();
            spot = _spot;
            pbmrc2 = _pbmrc2;
        })

        it('Should deploy smart contract', async () => {
            assert(pbmrc2.address !== '');
            assert(spot.address !== '');
        });

        it('PBMRC2 Should initialized with Spot token address', async () => {
            var pbm_spot = await pbmrc2.spotToken();
            assert.equal(spot.address, pbm_spot);
        });

    });


})