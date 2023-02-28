var RUSD = artifacts.require("RUSD");
var stockToken=artifacts.require("StockToken");
var BUSDToken=artifacts.require("BUSD");
module.exports = async(deployer)=> {
    deployer.deploy(RUSD,"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac","0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac");
    deployer.deploy(stockToken,"stock Token","ST","0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac");
    deployer.deploy(BUSDToken,"0x4830C8dAa8adeC73EE6E49f3198EdA8D3e4495Ac");
};