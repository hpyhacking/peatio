# Openware HDWallet plugin - BSC

This peatio plugin is using the openware HDWallet microservice to generate users wallets, sign and broadcast transactions.

This plugin with Openware HDWallet supports BNB native currency and BEP20 tokens on Binance Smart Chain (BSC) blockchain.

## Blockchain configuration

### Testnet configuration

| Key                  | Value                                           |
| -------------------- | ----------------------------------------------- |
| Name                 | BSC Testnet                                     |
| Client               | geth-bsc                                        |
| Server               | https://data-seed-prebsc-1-s1.binance.org:8545/ |
| Min confirmations    | 1                                               |
| Key                  | bsc-testnet                                     |
| Explorer address     | https://testnet.bscscan.com/address/#{address}  |
| Explorer transaction | https://testnet.bscscan.com/tx/#{txid}          |

#### Mainnet configuration

| Key                  | Value                                  |
| -------------------- | -------------------------------------- |
| Name                 | BSC Mainnet                            |
| Client               | geth-bsc                               |
| Server               | https://bsc-dataseed.binance.org/      |
| Explorer address     | https://bscscan.com/address/#{address} |
| Explorer transaction | https://bscscan.com/tx/#{txid}         |
| Min confirmations    | 12                                     |

## Currencies configuration

You need to configure at least the BNB currency which is the native token of BSC blockchain, then you can configure any BEP20 token.

To configure a BEP20 token, add the property `bep20_contract_address` to the currency with the smart contract address.

Here is a list of popular BEP20 tokens on testnet and mainnet:

| Currency ID | bep20_contract_address (Testnet)           | bep20_contract_address (Mainnet) | Base factor | Min deposit amount |
| ----------- | ------------------------------------------ | -------------------------------- | ----------- | ------------------ |
| BNB         |                                            |                                  | 18          | 0.01               |
| BUSD        | 0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee |                                  | 18          |                    |

## Wallets configuration

Wallets can be configured through Tower in `Settings > Wallets` section.

### Deposit wallet

| Key                 | Value                             | Description                                                  |
| ------------------- | --------------------------------- | ------------------------------------------------------------ |
| Name                | BNB/BEP20 Deposit Wallet          | Name of the wallet                                           |
| Status              | Active                            | Enable the wallet                                            |
| Blockchain key      | bsc-mainnet                       | Blockchain key configured before (*bsc-testnet* for testnet) |
| Gateway Client      | https://bsc-dataseed.binance.org/ | RPC REST of blockchain node (https://data-seed-prebsc-1-s1.binance.org:8545/ for testnet) |
| Address             | -                                 | The address of the deposit wallet is not used for BSC blockchain, you can set anything. |
| Kind                | deposit                           | Configure this wallet as a deposit wallet.                   |
| Maximum balance     | 0.0                               | Unused for deposit wallets.                                  |
| URI (in properties) | https://hdwallet/api/v2/hdwallet  | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  blockchain_key: "bsc-mainnet",
  name: "BNB/BEP20 Deposit Wallet",
  address: "-",
  gateway: "ow-hdwallet-bsc",
  kind: "deposit",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://bsc-dataseed.binance.org/"},
  max_balance: 0,
  status: "active"
)
```

### Hot wallet

| Key                 | Value                             | Description                                                  |
| ------------------- | --------------------------------- | ------------------------------------------------------------ |
| Name                | BNB/BEP20 Hot Wallet              |                                                              |
| Status              | Active                            | Enable the wallet                                            |
| Blockchain key      | bsc-mainnet                       | Blockchain key configured before (bsc-testnet* for testnet)  |
| Gateway Client      | https://bsc-dataseed.binance.org/ | RPC REST of blockchain node (https://data-seed-prebsc-1-s1.binance.org:8545/ for testnet) |
| Address             |                                   | Leave the address empty for peatio to generate it automatically. |
| Kind                | hot                               | Configure this wallet as a hot wallet.                       |
| Maximum balance     | 10000                             | Once this amount reached, deposits will be collected to **warm** and **cold** wallets. |
| URI (in properties) | https://hdwallet/api/v2/hdwallet  | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  blockchain_key: "bsc-mainnet",
  name: "BNB/BEP20 Hot Wallet",
  address: "",
  gateway: "ow-hdwallet-bsc",
  kind: "hot",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://bsc-dataseed.binance.org/"},
  max_balance: 10000,
  status: "active"
)
```



### Fee wallet

| Key                 | Value                             | Description                                                  |
| ------------------- | --------------------------------- | ------------------------------------------------------------ |
| Name                | BNB/BEP20 Fee Wallet              |                                                              |
| Status              | Active                            | Enable the wallet                                            |
| Blockchain key      | bsc-mainnet                       | Blockchain key configured before (bsc-testnet* for testnet)  |
| Gateway Client      | https://bsc-dataseed.binance.org/ | RPC REST of blockchain node (https://data-seed-prebsc-1-s1.binance.org:8545/ for testnet) |
| Address             |                                   | Leave the address empty for peatio to generate it automatically. |
| Kind                | fee                               | Configure this wallet as a hot wallet.                       |
| Maximum balance     |                                   |                                                              |
| URI (in properties) | https://hdwallet/api/v2/hdwallet  | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  blockchain_key: "bsc-mainnet",
  name: "BNB/BEP20 Fee Wallet",
  address: "",
  gateway: "ow-hdwallet-bsc",
  kind: "hot",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://bsc-dataseed.binance.org/"},
  max_balance: 10000,
  status: "active"
)
```