var RUSD = artifacts.require("RUSD");
var stockToken=artifacts.require("StockToken");
module.exports = async(deployer)=> {
    deployer.deploy(RUSD,"0xBCa528B365C5D45727b9D711a9fc0Bc084027716","0xBCa528B365C5D45727b9D711a9fc0Bc084027716");
    deployer.deploy(stockToken,"stock Token","ST","0xe5840CbA5f24c64db82f8f13d521811A7a5ad4D8","0x3b07836A939C7135c00FFc3BBD80609f30BC90E3");
};