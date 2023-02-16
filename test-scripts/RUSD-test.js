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
        await rusdToken.setRefWalletAddress("0xdF902EE0578351BEC5893bF21A1A1C3532561Bc7",{from:owner});
        assert(await rusdToken.refWalletAddress()== "0xdF902EE0578351BEC5893bF21A1A1C3532561Bc7");
    })
    it('Mint To specific Address by ref Wallet',async()=>{
        let rusdToken= await RUSD.deployed();
        let refWalletAddress=await rusdToken.refWalletAddress();
        await rusdToken.mint("0xdF902EE0578351BEC5893bF21A1A1C3532561Bc7",BigInt(10*10**18),{from:refWalletAddress});
        let balance=await rusdToken.balanceOf("0xdF902EE0578351BEC5893bF21A1A1C3532561Bc7");
        assert(balance.toString()==(10*10**18));
    })
    it('burn To specific Address by ref Wallet',async()=>{
        let rusdToken= await RUSD.deployed();
        let refWalletAddress=await rusdToken.refWalletAddress();
        await rusdToken.mint("0xdF902EE0578351BEC5893bF21A1A1C3532561Bc7",BigInt(10*10**18),{from:refWalletAddress});
        let balance=await rusdToken.balanceOf("0xdF902EE0578351BEC5893bF21A1A1C3532561Bc7");
        await rusdToken.burn("0xdF902EE0578351BEC5893bF21A1A1C3532561Bc7",balance,{from:refWalletAddress});
        balance=await rusdToken.balanceOf("0xdF902EE0578351BEC5893bF21A1A1C3532561Bc7");
        assert(balance.toString()==0);
    })
})


