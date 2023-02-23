const { assert } = require("console");

const stockT=artifacts.require("StockToken");

contract('stockToken Testing',async()=>{
    
    it('should contract deploy properly',async()=>{
        let stockToken= await stockT.deployed();
        assert(stockToken.address!=='');
    })
    
    it('Check Decimals of Stock Token ',async()=>{
        let stockToken= await stockT.deployed();
        let decimals=await stockToken.decimals();
        assert(decimals==18);
    })

    it('Update Ref Address',async()=>{
        let stockToken= await stockT.deployed();
        let owner=await stockToken.owner();
        await stockToken.setRefWalletAddress("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c",{from:owner});
        assert(await stockToken.refWalletAddress()== "0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c");
    })

    it('Update RUSD Address',async()=>{
        let stockToken= await stockT.deployed();
        let owner=await stockToken.owner();
        await stockToken.setRusdAddress("0x3b07836A939C7135c00FFc3BBD80609f30BC90E3",{from:owner});
        assert(await stockToken.rusdAddress()== "0x3b07836A939C7135c00FFc3BBD80609f30BC90E3");
    }) 

    it('Mint To specific Address by RUSD Wallet',async()=>{
        let stockToken= await stockT.deployed();
        let rusdAddress=await stockToken.rusdAddress();
        await stockToken.mint("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c",BigInt(10*10**18),{from:rusdAddress});
        let balance=await stockToken.balanceOf("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c");
        assert(balance.toString()==(10*10**18));
    })
    it('burn To specific Address by RUSD Wallet',async()=>{
        let stockToken= await stockT.deployed();
        let rusdAddress=await stockToken.rusdAddress();
        await stockToken.mint("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c",BigInt(10*10**18),{from:rusdAddress});
        let balance=await stockToken.balanceOf("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c");
        await stockToken.burn("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c",balance,{from:rusdAddress});
        balance=await stockToken.balanceOf("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c");
        assert(balance.toString()==0);
    })
})


