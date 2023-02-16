const { assert } = require("console");

const BUSD=artifacts.require("BUSD");

contract('BUSD Testing',async()=>{
    
    it('should contract deploy properly',async()=>{
        let busdToken= await BUSD.deployed();
        assert(busdToken.address!=='');
    })
    
    it('Check Decimals of RUSD Token ',async()=>{
        let busdToken= await BUSD.deployed();
        let decimals=await busdToken.decimals();
        assert(decimals==18);
    })

    it('Update Ref Address',async()=>{
        let busdToken= await BUSD.deployed();
        let owner=await busdToken.owner();
        await busdToken.setRefWalletAddress("0x4383e978A54f61691897659ecC824D3421a38a3b",{from:owner});
        assert(await busdToken.refWalletAddress()== "0x4383e978A54f61691897659ecC824D3421a38a3b");
    })
    it('Mint To specific Address by ref Wallet',async()=>{
        let busdToken= await BUSD.deployed();
        let refWalletAddress=await busdToken.refWalletAddress();
        await busdToken.mint("0x4383e978A54f61691897659ecC824D3421a38a3b",BigInt(10*10**18),{from:refWalletAddress});
        let balance=await busdToken.balanceOf("0x4383e978A54f61691897659ecC824D3421a38a3b");
        assert(balance.toString()==(10*10**18));
    })
    it('burn To specific Address by ref Wallet',async()=>{
        let busdToken= await BUSD.deployed();
        let refWalletAddress=await busdToken.refWalletAddress();
        await busdToken.mint("0x4383e978A54f61691897659ecC824D3421a38a3b",BigInt(10*10**18),{from:refWalletAddress});
        let balance=await busdToken.balanceOf("0x4383e978A54f61691897659ecC824D3421a38a3b");
        await busdToken.burn("0x4383e978A54f61691897659ecC824D3421a38a3b",balance,{from:refWalletAddress});
        balance=await busdToken.balanceOf("0x4383e978A54f61691897659ecC824D3421a38a3b");
        assert(balance.toString()==0);
    })
})


