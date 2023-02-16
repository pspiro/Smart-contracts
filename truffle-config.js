var HDWalletProvider = require("truffle-hdwallet-provider");
const MNEMONIC = '8a82ccf3660f7ba5a914cd1823b7e4b9ddea83a85aa30f326d089dcefd5f23b0';

module.exports = {
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    bscscan: 'EGAI9ABPT2XFP4R2H6QN1WWD4HXIF6DGYJ'
  },
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    bsctest: {
      networkCheckTimeout: 10000, 
      provider: () => new HDWalletProvider(MNEMONIC, `https://data-seed-prebsc-1-s1.binance.org:8545/`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 2000,
      skipDryRun: true
    }
  },// Configure your compilerscn@#12345sourabh
  compilers: {
    solc: {
      version: "0.8.4",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 200
       },
       evmVersion: "byzantium"
      }
    }
  }
};