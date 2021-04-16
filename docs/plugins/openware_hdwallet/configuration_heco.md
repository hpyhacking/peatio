# Openware HDWallet plugin - Huobi HECO Chain

This peatio plugin is using the openware HDWallet microservice to generate users wallets, sign and broadcast transactions.

This plugin with openware HDWallet supports HT native currency and HRC20 tokens on Huobi HECO chain.

## Blockchain configuration

You need to create a blockchain entry in peatio before configuring wallets. 
Blockchains can be configured through Tower in `Settings > Blockchains` section.

#### Testnet configuration

| Key                  | Value                                           |
| -------------------- | ----------------------------------------------- |
| Name                 | Heco Testnet                                    |
| Client               | geth-heco                                       |
| Server               | https://http-testnet.hecochain.com              |
| Min confirmations    | 1                                               |
| Key                  | heco-testnet                                    |
| Explorer address     | https://testnet.hecoinfo.com/address/#{address} |
| Explorer transaction | https://testnet.hecoinfo.com/tx/#{txid}         |

#### Mainnet configuration

| Key                  | Value                                   |
| -------------------- | --------------------------------------- |
| Name                 | Heco Mainnet                            |
| Client               | geth-heco                               |
| Server               | https://http-mainnet.hecochain.com      |
| Min confirmations    | 20                                      |
| Key                  | heco-mainnet                            |
| Explorer address     | https://hecoinfo.com/address/#{address} |
| Explorer transaction | https://hecoinfo.com/tx/#{txid}         |

##Currencies configuration

You need to configure at least the HT currency which is the native token of HECO blockchain, then you can configure any HRC20 token.

To configure a HRC20 token, add the property `hrc20_contract_address` to the currency with the smart contract address

Here is a list of popular HRC20 token on testnet and mainnet:

| Currency ID | hrc20_contract_address (Testnet)           | hrc20_contract_address (Mainnet)           | Base factor | Min deposit amount |
| ----------- | ------------------------------------------ | ------------------------------------------ | ----------- | ------------------ |
| HT          |                                            |                                            | 18          | 0.05               |
| USDT        | 0x04f535663110a392a6504839beed34e019fdb4e0 |                                            | 6           |                    |
| WBTC        | 0x84c6ae2888f954ea041fc541408d302f163f8194 | 0x70d171d269d964d14af9617858540061e7be9ef1 | 8           |                    |
| HBTC        | 0x1D8684e6CdD65383AfFd3D5CF8263fCdA5001F13 | 0x66a79d23e58475d2738179ca52cd0b41d73f0bea | 18          |                    |
| HETH        | 0xfeB76Ae65c11B363Bd452afb4A7eC59925848656 | 0x64ff637fb478863b7468bc97d30a5bf3a428a1fd | 18          |                    |
| HUSDT       |                                            | 0xa71edc38d189767582c38a3145b5873052c3e47a | 18          |                    |
| HDOT        | 0xAbE5acA6C8996482b6a7CD3f63A02FaBCc20BAE7 | 0xa2c49cee16a5e5bdefde931107dc1fae9f7773e3 | 18          |                    |
| HLTC        | 0x13B456e06a401B5aF98c5C3B4937b84c9a700FD2 | 0xecb56cf772b5c9a6907fb7d32387da2fcbfb63b4 | 18          |                    |
| HBCH        |                                            | 0xef3cebd77e0c52cb6f60875d9306397b5caca375 | 18          |                    |
| HUNI        | 0x4d879F43f6644784248553Ee91A2e4Dfb06fE0BC | 0x22c54ce8321a4015740ee1109d9cbc25815c46e6 | 18          |                    |
| HLINK       | 0x3E24e9d2c824B0ac2C82edc931B67252099B8e79 | 0x9e004545c59d359f6b7bfb06a26390b087717b42 | 18          |                    |
| HUSDC       | 0xd459Dad367788893c17c09e17cFBF0bf25c62833 | 0x9362bbef4b8313a8aa9f0c9808b80577aa26b73b | 6           |                    |
| HFIL        | 0x58BBCE4CB3e17c7984e9E3c22337396f1b5D552E | 0xae3a768f9ab104c69a7cd6041fe16ffa235d1810 | 18          |                    |
| HBSV        | 0xEa25003CE930199bf0AAdF8A55F196bCa32a73C2 | 0xc2cb6b5357ccce1b99cd22232942d9a225ea4eb1 | 18          |                    |
| HFTT        |                                            | 0xc7f7a54892b78b5c812c58d9df8035fce9f4d445 | 18          |                    |
| HAAVE       | 0x29781B8dA7F4f0F467c326F8D7B39143008E32a0 | 0x202b4936fe1a82a4965220860ae46d7d3939bb25 | 18          |                    |
| HXTZ        | 0xa2283Bc148AE01b009237303B56fE244fbf565C8 | 0x45e97dad828ad735af1df0473fc2735f0fd5330c | 18          |                    |
| WHT         |                                            | 0x5545153ccfca01fbd7dd11c0b23ba694d9509a6f | 18          |                    |
| HDAI        | 0x60d64Ef311a4F0E288120543A14e7f90E76304c6 | 0x3d760a45d0887dfd89a2f5385a236b29cb46ed2a | 18          |                    |
| HMKR        | 0x8F8c70e5E9A013B32600e338e4bBE6364caAF5BB | 0x34d75515090902a513f009f4505a750efaad63b0 | 18          |                    |



## Wallets configuration

Wallets can be configured through Tower in `Settings > Wallets` section.

### Deposit wallet

| Key                 | Value                              | Description                                                  |
| ------------------- | ---------------------------------- | ------------------------------------------------------------ |
| Name                | HT/HRC20 Deposit Wallet            |                                                              |
| Status              | Active                             | Enable the wallet                                            |
| Blockchain key      | heco-mainnet                       | Blockchain key configured before (*heco-testnet* for testnet) |
| Gateway Client      | https://http-mainnet.hecochain.com | RPC REST of blockchain node (https://http-testnet.hecochain.com for testnet) |
| Address             | -                                  | The address of the deposit wallet is not used for HECO blockchain. |
| Kind                | deposit                            | Configure this wallet as a deposit wallet.                   |
| Maximum balance     | 0.0                                | Unused for deposit wallets.                                  |
| URI (in properties) | https://hdwallet/api/v2/hdwallet   | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  blockchain_key: "heco-mainnet",
  name: "HT/HRC20 Deposit Wallet",
  address: "-",
  gateway: "ow-hdwallet-heco",
  kind: "deposit",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://http-mainnet.hecochain.com"},
  max_balance: 0,
  currency_ids: ["ht"],
  status: "active"
)
```

### Hot wallet

| Key                 | Value                              | Description                                                  |
| ------------------- | ---------------------------------- | ------------------------------------------------------------ |
| Name                | HT/HRC20 Hot Wallet                |                                                              |
| Status              | Active                             | Enable the wallet                                            |
| Blockchain key      | heco-mainnet                       | Blockchain key configured before (*heco-testnet* for testnet) |
| Gateway Client      | https://http-mainnet.hecochain.com | RPC REST of blockchain node (https://http-testnet.hecochain.com for testnet) |
| Address             |                                    | Leave the address empty for peatio to generate it automatically. |
| Kind                | hot                                | Configure this wallet as a hot wallet.                       |
| Maximum balance     | 10000                              | Once this amount reached, deposits will be collected to **warm** and **cold** wallets. |
| URI (in properties) | https://hdwallet/api/v2/hdwallet   | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  blockchain_key: "heco-mainnet",
  name: "HT/HRC20 Hot Wallet",
  address: "",
  gateway: "ow-hdwallet-heco",
  kind: "hot",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://http-mainnet.hecochain.com"},
  max_balance: 10000,
  currency_ids: ["ht"],
  status: "active"
)
```



### Fee wallet

| Key                 | Value                              | Description                                                  |
| ------------------- | ---------------------------------- | ------------------------------------------------------------ |
| Name                | HT/HRC20 Fee Wallet                |                                                              |
| Status              | Active                             | Enable the wallet                                            |
| Blockchain key      | heco-mainnet                       | Blockchain key configured before (*heco-testnet* for testnet) |
| Gateway Client      | https://http-mainnet.hecochain.com | RPC REST of blockchain node (https://http-testnet.hecochain.com for testnet) |
| Address             |                                    | Leave the address empty for peatio to generate it automatically. |
| Kind                | fee                                | Configure this wallet as a hot wallet.                       |
| Maximum balance     |                                    |                                                              |
| URI (in properties) | https://hdwallet/api/v2/hdwallet   | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  name: "HT/HRC20 Fee Wallet",
  blockchain_key: "heco-mainnet",
  address: "",
  gateway: "ow-hdwallet-heco",
  kind: "hot",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://http-mainnet.hecochain.com"},
  max_balance: 10000,
  currency_ids: ["ht"],
  status: "active"
)
```
