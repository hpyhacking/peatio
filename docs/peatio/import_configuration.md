# Peatio Import Configuration API

This doc describes how you can import configuration for currencies/wallets/blockchains using Admin API

### Example for configuration

1. Prepare json/yaml file for your configuration with the following format

Example of yaml configuration file

```yaml
blockchains:
  - key:               prt-kovan
    name:              Ethereum Kovan
    client:            parity                 # API client name.
    server:            http://127.0.0.1:8545  # Public Ethereum node endpoint. IMPORTANT: full syncmode.
    height:            2500000                # Initial block number from which sync will be started.
    min_confirmations: 6                      # Minimal confirmations needed for withdraw and deposit confirmation.
    explorer:
      address:         https://kovan.etherscan.io/address/#{address}
      transaction:     https://kovan.etherscan.io/tx/#{txid}
    status:            disabled

currencies:
  - id:                     usd
    name:                   US Dollar
    type:                   fiat
    precision:              2
    base_factor:            1
    visible:                true
    deposit_enabled:        true
    withdrawal_enabled:     true
    min_deposit_amount:     0
    min_collection_amount:  0
    withdraw_limit_24h:     100
    withdraw_limit_72h:     200
    deposit_fee:            0
    withdraw_fee:           0
    position:               1
    options:                {}
```


Example of json configuration file

```json
{
  "blockchains": [
    {
      "key": "eth-testnet",
      "name": "Ethereum Testnet",
      "client": "parity",
      "height": 8670000,
      "explorer_address": "https://etherscan.io/address/#{address}",
      "explorer_transaction": "https://etherscan.io/tx/#{txid}",
      "min_confirmations": 6,
      "status": "disabled"
    }
  ],
  "wallets": [
    {
      "blockchain_key": "eth-testnet",
      "name": "Ethereum Deposit Wallet",
      "address": "0x828058628DF254Ebf252e0b1b5393D1DED91E369",
      "kind": "deposit",
      "max_balance": 0.0,
      "status": "active",
      "gateway": "geth",
      "uri": "http://127.0.0.1:8545",
      "secret": "changeme",
      "plain_settings": {
        "external_wallet_id": 1
      },
      "settings": {
        "uri": "http://127.0.0.1:8545"
      }
    }
  ]
}
```

2. Go to Tower in Settings Tab (blockchains or wallets configuration) or Exchange Tab (currencies configuration) -> find Import Button in the panel -> load json/yaml configuration file -> click Submit button.

Also you can use directly Admin API with POST request to `api/v2/peatio/admin/import_configs`

Example with curl:

```bash
curl -X POST -F 'file=@spec/resources/import_configs/data.json' 'https://opendax.cloud/api/v2/admin/import_configs'
```

### Rules and exceptions

1. If currency/blockchain/wallet doesnt exist in peatio DB, system will create this entity.

2. If currency/blockchain/wallet exists in peatio DB, system will skip this entity.

3. If there is some error during currency/blockchain/wallet creation, system will skip this entity and process next one.
