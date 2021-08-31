# Openware HDWallet plugin - Features

## Generate address

Make sure you have a deposit wallet configured, see [Ethereum configuration](./configuration_ethereum.md), [HECO configuration](./configuration_heco.md) or [BSC configuration](./configuration_bsc.md) for details.

There are 3 options to test:

### From rails console

```ruby
# Find deposit wallet and save it to variable
w = Wallet.find(id)
service = WalletService.new(w)
service.create_address!(uid, {})
# response
{
  "address":"0x6876447bF1ab4efc09740e242eaED2Ab389509a4",
  "passphrase":"2ee7dc93b6581c3ac31f62d32257477e",
  "coin-type":"eth",
  "wallet-index":20004
}
```

### From API call

`/api/v2/peatio/account/deposit_address/:currency`

```json
// response
{
  "currencies": ["bigo","cro","eth"],
  "address":"0xb06dd7f8ee1852cf3f9e43b9a703a06f8e28d31f",
  "state":"active"
}
```

### From peatio daemon

To check if there is some problem with user address generation you should check `amqp-daemon-deposit-coin-address` daemon logs

To verify address information has right format

```ruby
# Find deposit wallet and member configuration
wallet = Wallet.find(id)
member = Member.find_by(email 'your email')
# Find member payment address
payment_address = PaymentAddress.find_by(wallet_id: wallet.id, member_id: member.id)
# In payment address secret should be information about passphrase (encrypted password from private key)
payment_address.secret
"a4ee099cc541dd222dc24ea546dd46c6"
# In payment address details should be information about wallet index, and coin type
payment_address.details
{"wallet_index"=>2, "coin_type"=>"eth"}
```

## Create transaction

To test create transaction you should have all configuration described on `create_address` step for all wallets related to your currency (especially deposit, hot wallet)

Be sure that you have blockchain configured before doing transaction and this blockchain-key connected both for currency and wallets!
Blockchain `server` parameter should be the same as `url` parameter in wallet settings (blockchain node url or infura url)

### Deposit

- Deposit some funds to your created address
- Check logs of `daemon-deposit`
- You can get information about deposit status from rails console, admin tower or your wallet page

### Withdraw

- Transfer funds from your account
- Check logs of `amqp-daemon-withdraw-coin` about withdraw status from rails console, admin tower or your wallet page

## Fetch wallet balance
To test load balance you should have all configuration described on `create_address` step for all wallets related to your currency (deposit, hot, warm, cold)

There are 2 options to test:

### From rails console

Find deposit wallet and save it to variable:

```ruby
w = Wallet.find(id)
w.current_balance
# response
{
  "balance":216380800000000000
}
```

### From Admin API call
`/api/v2/peatio/admin/wallets/:id`

Example of response:

```json
{
  "id": 1,
  "name": "Test wallet",
  "kind": "deposit",
  "currencies": ["fth","seele"],
  "address": "changeme",
  "gateway": "parity",
  "max_balance": "212.0",
  "balance": {
    "fth": "2.3",
    "seele": "223.3"
  },
  "blockchain_key": "eth-testnet",
  "status": "active",
  "created_at": "2020-09-10T17:53:03+02:00",
  "updated_at": "2020-10-20T05:00:49+02:00"
}
```
