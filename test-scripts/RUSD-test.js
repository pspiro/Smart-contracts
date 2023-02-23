const { assert } = require("console");

const RUSD=artifacts.require("RUSD");

contract('RUSD Testing',async()=>{

    it('should contract deploy properly',async()=>{
        let rusdToken= await RUSD.deployed();
        assert(rusdToken.address!=='');
    })

    it('Check Decimals of RUSD Token ',async()=>{
        let rusdToken= await RUSD.deployed();
        let decimals=await rusdToken.decimals();
        assert(decimals==18);
    })

    it('Update Ref Address',async()=>{
        let rusdToken= await RUSD.deployed();
        let owner=await rusdToken.owner();
        await rusdToken.setRefWalletAddress("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c",{from:owner});
        assert(await rusdToken.refWalletAddress()== "0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c");
    })
})

