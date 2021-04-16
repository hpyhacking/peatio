# Openware HDWallet plugin - Ethereum

This peatio plugin is using the openware HDWallet microservice to generate users wallets, sign and broadcast transactions.

This plugin with Openware HDWallet supports ETH native currency and ERC20 tokens on Ethereum blockchain.

## Blockchain configuration

### Rinkeby Testnet configuration

| Key                  | Value                                             |
| -------------------- | ------------------------------------------------- |
| Name                 | ETH Testnet                                       |
| Client               | parity                                            |
| Server               | https://rinkeby.infura.io/v3/${INFURA PROJECT ID} |
| Min confirmations    | 1                                                 |
| Key                  | eth-rinkeby                                       |
| Explorer address     | https://rinkeby.etherscan.io/address/#{address}   |
| Explorer transaction | https://rinkeby.etherscan.io/tx/#{txid}           |

#### Mainnet configuration

| Key                  | Value                                             |
| -------------------- | ------------------------------------------------- |
| Name                 | ETH Mainnet                                       |
| Client               | parity                                            |
| Server               | https://mainnet.infura.io/v3/${INFURA PROJECT ID} |
| Key                  | eth-mainnet                                       |
| Explorer address     | https://etherscan.io/address/#{address}           |
| Explorer transaction | https://etherscan.io/tx/#{txid}                   |
| Min confirmations    | 10                                                |

## Wallets configuration

Wallets can be configured through Tower in `Settings > Wallets` section.

### Deposit wallet

| Key                 | Value                                             | Description                                                  |
| ------------------- | ------------------------------------------------- | ------------------------------------------------------------ |
| Name                | ETH/ERC20 Deposit Wallet                          | Name of the wallet                                           |
| Status              | Active                                            | Enable the wallet                                            |
| Blockchain key      | eth-mainnet                                       | Blockchain key configured before (*eth-rinkeby* for Rinkeby testnet) |
| Gateway Client      | https://mainnet.infura.io/v3/${INFURA PROJECT ID} | RPC REST of blockchain node (https://rinkeby.infura.io/v3/${INFURA PROJECT ID} for rinkeby testnet) |
| Address             | -                                                 | The address of the deposit wallet is not used for Ethereum blockchain, you can set anything. |
| Kind                | deposit                                           | Configure this wallet as a deposit wallet.                   |
| Maximum balance     | 0.0                                               | Unused for deposit wallets.                                  |
| URI (in properties) | https://hdwallet/api/v2/hdwallet                  | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  blockchain_key: "eth-mainnet",
  name: "ETH/ERC20 Deposit Wallet",
  address: "-",
  gateway: "ow-hdwallet-eth",
  kind: "deposit",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://mainnet.infura.io/v3/${INFURA PROJECT ID}"},
  max_balance: 0,
  status: "active"
)
```

### Hot wallet

| Key                 | Value                                             | Description                                                  |
| ------------------- | ------------------------------------------------- | ------------------------------------------------------------ |
| Name                | ETH/ERC20 Hot Wallet                              |                                                              |
| Status              | Active                                            | Enable the wallet                                            |
| Blockchain key      | eth-mainnet                                       | Blockchain key configured before (*eth-rinkeby* for Rinkeby testnet) |
| Gateway Client      | https://mainnet.infura.io/v3/${INFURA PROJECT ID} | RPC REST of blockchain node (https://rinkeby.infura.io/v3/${INFURA PROJECT ID} for rinkeby testnet) |
| Address             |                                                   | Leave the address empty for peatio to generate it automatically. |
| Kind                | hot                                               | Configure this wallet as a hot wallet.                       |
| Maximum balance     | 10000                                             | Once this amount reached, deposits will be collected to **warm** and **cold** wallets. |
| URI (in properties) | https://hdwallet/api/v2/hdwallet                  | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  blockchain_key: "eth-mainnet",
  name: "ETH/ERC20 Hot Wallet",
  address: "",
  gateway: "ow-hdwallet-eth",
  kind: "hot",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://mainnet.infura.io/v3/${INFURA PROJECT ID}"},
  max_balance: 10000,
  status: "active"
)
```



### Fee wallet

| Key                 | Value                                             | Description                                                  |
| ------------------- | ------------------------------------------------- | ------------------------------------------------------------ |
| Name                | ETH/ERC20 Fee Wallet                              |                                                              |
| Status              | Active                                            | Enable the wallet                                            |
| Blockchain key      | eth-mainnet                                       | Blockchain key configured before (*eth-rinkeby* for Rinkeby testnet) |
| Gateway Client      | https://mainnet.infura.io/v3/${INFURA PROJECT ID} | RPC REST of blockchain node (https://rinkeby.infura.io/v3/${INFURA PROJECT ID} for rinkeby testnet) |
| Address             |                                                   | Leave the address empty for peatio to generate it automatically. |
| Kind                | fee                                               | Configure this wallet as a hot wallet.                       |
| Maximum balance     |                                                   |                                                              |
| URI (in properties) | https://hdwallet/api/v2/hdwallet                  | URL of the openware HDWallet microservice                    |

Example from the console:

```ruby
Wallet.create!(
  blockchain_key: "eth-mainnet",
  name: "ETH/ERC20 Fee Wallet",
  address: "",
  gateway: "ow-hdwallet-eth",
  kind: "hot",
  settings: {uri: "https://hdwallet/api/v2/hdwallet", gateway_url: "https://mainnet.infura.io/v3/${INFURA PROJECT ID}"},
  max_balance: 10000,
  status: "active"
)
```

