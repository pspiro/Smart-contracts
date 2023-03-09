const { assert } = require("console");

const RUSD=artifacts.require("RUSD");
const BUSDToken=artifacts.require("BUSD");
const stockToken=artifacts.require("StockToken");
contract('RUSD Testing',async()=>{

    it('should contract deploy properly',async()=>{
        let rusdToken= await RUSD.deployed();
        assert(rusdToken.address!=='');
    })

    it('Check Decimals of RUSD Token ',async()=>{
        let rusdToken= await RUSD.deployed();
        let decimals=await rusdToken.decimals();
        assert(decimals==6);
    })

    it('Update Ref Address',async()=>{
        let rusdToken= await RUSD.deployed();
        let owner=await rusdToken.owner();
        await rusdToken.setRefWalletAddress("0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac",{from:owner});
        assert(await rusdToken.refWalletAddress()== "0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac");
    })

    it('Add Admin Address',async()=>{
        let rusdToken= await RUSD.deployed();
        let owner=await rusdToken.owner();
        await rusdToken.addOrRemoveAdmin("0x25F1d0d1D4cAaeFEE88B8f66E44AB594F515431D",true,{from:owner});
        assert(await rusdToken.admins("0x25F1d0d1D4cAaeFEE88B8f66E44AB594F515431D")== true);
    })

    it('Remove Admin Address',async()=>{
        let rusdToken= await RUSD.deployed();
        let owner=await rusdToken.owner();
        await rusdToken.addOrRemoveAdmin("0x25F1d0d1D4cAaeFEE88B8f66E44AB594F515431D",false,{from:owner});
        assert(await rusdToken.admins("0x25F1d0d1D4cAaeFEE88B8f66E44AB594F515431D")== false);
    })

    it('Buy Stock using BUSD',async()=>{
        let rusdToken= await RUSD.deployed();
        let BUSD=await BUSDToken.deployed();
        let stoken=await stockToken.deployed();
        await stoken.setRusdAddress(rusdToken.address,{from:await stoken.owner()})
         await rusdToken.buyStock("0x2c2b2D891A782124f2a21f56adCd5475d8790615",BUSD.address,stoken.address,0,BigInt(100*10**6),{from:"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac"});
        let RUSDbalance=await stoken.balanceOf("0x2c2b2D891A782124f2a21f56adCd5475d8790615");
        console.log(" stock balance",RUSDbalance.toString());
    })

    it('Buy Stock using BUSD with balance',async()=>{
        let rusdToken= await RUSD.deployed();
        let BUSD=await BUSDToken.deployed();
        let stoken=await stockToken.deployed();
        await BUSD.mint("0x2c2b2D891A782124f2a21f56adCd5475d8790615",BigInt(10000*10**18),{from:"0x2c2b2D891A782124f2a21f56adCd5475d8790615"});
        let balance=await BUSD.balanceOf("0x2c2b2D891A782124f2a21f56adCd5475d8790615");
        await stoken.setRusdAddress(rusdToken.address,{from:await stoken.owner()})
        await BUSD.approve(rusdToken.address,balance.toString(),{from:"0x2c2b2D891A782124f2a21f56adCd5475d8790615"});
        await rusdToken.buyStock("0x2c2b2D891A782124f2a21f56adCd5475d8790615",BUSD.address,stoken.address,balance.toString(),BigInt(100*10**6),{from:"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac"});
        let RUSDbalance=await stoken.balanceOf("0x2c2b2D891A782124f2a21f56adCd5475d8790615");
        console.log(" stock balance",RUSDbalance.toString());
    })

    it('Buy and Sell Stock using RUSD',async()=>{
        let rusdToken= await RUSD.deployed();
        let stoken=await stockToken.deployed();
        await stoken.setRusdAddress(rusdToken.address,{from:await stoken.owner()})
        await rusdToken.buyStock("0x2c2b2D891A782124f2a21f56adCd5475d8790615",rusdToken.address,stoken.address,0,BigInt(100),{from:"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac"});
        await rusdToken.sellStock("0x2c2b2D891A782124f2a21f56adCd5475d8790615",rusdToken.address,stockToken.address,10000,BigInt(50),{from:"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac"});
        await rusdToken.buyStock("0x2c2b2D891A782124f2a21f56adCd5475d8790615",rusdToken.address,stoken.address,1000,BigInt(100),{from:"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac"});
        let RUSDbalance=await rusdToken.balanceOf("0x2c2b2D891A782124f2a21f56adCd5475d8790615");
        let stocktokenbalance=await stoken.balanceOf("0x2c2b2D891A782124f2a21f56adCd5475d8790615");
        assert(RUSDbalance.toString()==9000);
        assert(stocktokenbalance.toString()==200000150);
    })

    it('Sell RUSD Tokens',async()=>{
        let rusdToken= await RUSD.deployed();
        let BUSD=await BUSDToken.deployed();
        await BUSD.mint("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c",BigInt(1000000),{from:"0x2c2b2D891A782124f2a21f56adCd5475d8790615"});
        let balance=await BUSD.balanceOf("0xbc5f2aB7f250Eec58DB8A9FC88c8815673D6b13c");
        let RUSDbalance=await rusdToken.balanceOf("0x2c2b2D891A782124f2a21f56adCd5475d8790615");
        console.log("RUSD Balcne before sell",RUSDbalance.toString());
        await BUSD.approve(rusdToken.address,5000,{from:"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac"});
        await rusdToken.sellRusd("0x2c2b2D891A782124f2a21f56adCd5475d8790615",BUSD.address,5000,5000,{from:"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac"})
        RUSDbalance=await rusdToken.balanceOf("0x2c2b2D891A782124f2a21f56adCd5475d8790615");
         balance=await BUSD.balanceOf("0x2c2b2D891A782124f2a21f56adCd5475d8790615");
        console.log("RUSD Balcne after sell",RUSDbalance.toString());
        assert(RUSDbalance.toString()==4000);
        assert(balance.toString()==5000);
    })
})
