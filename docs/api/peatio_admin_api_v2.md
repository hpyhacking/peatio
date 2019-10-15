# Peatio Admin API v2
Admin API high privileged API with RBAC.

## Version: 2.3.43

**Contact information:**  
openware.com  
https://www.openware.com  
hello@openware.com  

**License:** https://github.com/rubykube/peatio/blob/master/LICENSE.md

### /adjustments/action

#### POST
##### Description:

Accepts adjustment and creates operations or reject adjustment.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique adjustment identifier in database. | Yes | integer |
| action | formData | Adjustment action all available actions: [:accept, :reject] | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Accepts adjustment and creates operations or reject adjustment. | [Adjustment](#adjustment) |

### /adjustments/new

#### POST
##### Description:

Create new adjustment.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| reason | formData | Adjustment reason. | Yes | string |
| description | formData | Adjustment description. | Yes | string |
| category | formData | Adjustment category | Yes | string |
| amount | formData | Adjustment amount. | Yes | double |
| currency_id | formData | Adjustment currency ID. | Yes | string |
| asset_account_code | formData | Adjustment asset account code. | Yes | integer |
| receiving_account_code | formData | Adjustment receiving account code. | Yes | integer |
| receiving_member_uid | formData | Adjustment receiving account code. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new adjustment. | [Adjustment](#adjustment) |

### /adjustments/{id}

#### GET
##### Description:

Get adjustment by ID

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Adjsustment Identifier in Database | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get adjustment by ID | [Adjustment](#adjustment) |

### /adjustments

#### GET
##### Description:

Get all adjustments, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Deposit currency id. | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| state | query | Adjustment's state. | No | string |
| category | query | Adjustment category | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all adjustments, result is paginated. | [ [Adjustment](#adjustment) ] |

### /orders/cancel

#### POST
##### Description:

Cancel all orders.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | formData | Unique order id. | Yes | string |
| side | formData | If present, only sell orders (asks) or buy orders (bids) will be cancelled. | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Cancel all orders. |

### /orders/{id}/cancel

#### POST
##### Description:

Cancel an order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique order id. | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Cancel an order. |

### /orders

#### GET
##### Description:

Get all orders, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | No | string |
| state | query | Filter order by state. | No | string |
| ord_type | query | Filter order by ord_type. | No | string |
| price | query | Price for each unit. e.g.If you want to sell/buy 1 btc at 3000 usd, the price is '3000.0' | No | double |
| origin_volume | query | The amount user want to sell/buy.An order could be partially executed,e.g. an order sell 5 btc can be matched with a buy 3 btc order,left 2 btc to be sold; in this case the order's volume would be '5.0',its remaining_volume would be '2.0', its executed volume is '3.0'. | No | double |
| type | query | Filter order by type. | No | string |
| email | query | Member email. | No | string |
| uid | query | Member UID. | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all orders, result is paginated. | [ [Order](#order) ] |

### /blockchains/update

#### POST
##### Description:

Update blockchain.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique blockchain identifier in database. | Yes | integer |
| key | formData | Unique key to identify blockchain. | No | string |
| name | formData | A name to identify blockchain. | No | string |
| client | formData | Integrated blockchain client. | No | string |
| server | formData | Blockchain server url. | No | string |
| height | formData | The number of blocks preceding a particular block on blockchain. | No | integer |
| explorer_transaction | formData | Blockchain explorer transaction template. | No | string |
| explorer_address | formData | Blockchain explorer address template. | No | string |
| status | formData | Blockchain status (active/disabled). | No | string |
| min_confirmations | formData | Minimum number of confirmations. | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update blockchain. | [Blockchain](#blockchain) |

### /blockchains/new

#### POST
##### Description:

Create new blockchain.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | formData | Unique key to identify blockchain. | Yes | string |
| name | formData | A name to identify blockchain. | Yes | string |
| client | formData | Integrated blockchain client. | Yes | string |
| height | formData | The number of blocks preceding a particular block on blockchain. | Yes | integer |
| explorer_transaction | formData | Blockchain explorer transaction template. | No | string |
| explorer_address | formData | Blockchain explorer address template. | No | string |
| server | formData | Blockchain server url. | No | string |
| status | formData | Blockchain status (active/disabled). | No | string |
| min_confirmations | formData | Minimum number of confirmations. | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new blockchain. | [Blockchain](#blockchain) |

### /blockchains/{id}

#### GET
##### Description:

Get a blockchain.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique blockchain identifier in database. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a blockchain. | [Blockchain](#blockchain) |

### /blockchains/clients

#### GET
##### Description:

Get available blockchain clients.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get available blockchain clients. |

### /blockchains

#### GET
##### Description:

Get all blockchains, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all blockchains, result is paginated. | [ [Blockchain](#blockchain) ] |

### /currencies/update

#### POST
##### Description:

Update currency.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| name | formData | Currency name | No | string |
| deposit_fee | formData | Currency deposit fee | No | double |
| min_deposit_amount | formData | Minimal deposit amount | No | double |
| min_collection_amount | formData | Minimal collection amount. | No | double |
| withdraw_fee | formData | Currency withdraw fee | No | double |
| min_withdraw_amount | formData | Minimal withdraw amount | No | double |
| withdraw_limit_24h | formData | Currency 24h withdraw limit | No | double |
| withdraw_limit_72h | formData | Currency 72h withdraw limit | No | double |
| position | formData | Currency position. | No | integer |
| options | formData | Currency options. | No | json |
| visible | formData | Currency display status (true/false). | No | boolean |
| deposit_enabled | formData | Currency deposit possibility status (true/false). | No | boolean |
| withdrawal_enabled | formData | Currency withdrawal possibility status (true/false). | No | boolean |
| precision | formData | Currency precision. | No | integer |
| icon_url | formData | Currency icon | No | string |
| code | formData | Unique currency code. | Yes | string |
| symbol | formData | Currency symbol | No | string |
| blockchain_key | formData | Associated blockchain key which will perform transactions synchronization for currency. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update currency. | [Currency](#currency) |

### /currencies/new

#### POST
##### Description:

Create new currency.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| name | formData | Currency name | No | string |
| deposit_fee | formData | Currency deposit fee | No | double |
| min_deposit_amount | formData | Minimal deposit amount | No | double |
| min_collection_amount | formData | Minimal collection amount. | No | double |
| withdraw_fee | formData | Currency withdraw fee | No | double |
| min_withdraw_amount | formData | Minimal withdraw amount | No | double |
| withdraw_limit_24h | formData | Currency 24h withdraw limit | No | double |
| withdraw_limit_72h | formData | Currency 72h withdraw limit | No | double |
| position | formData | Currency position. | No | integer |
| options | formData | Currency options. | No | json |
| visible | formData | Currency display status (true/false). | No | boolean |
| deposit_enabled | formData | Currency deposit possibility status (true/false). | No | boolean |
| withdrawal_enabled | formData | Currency withdrawal possibility status (true/false). | No | boolean |
| precision | formData | Currency precision. | No | integer |
| icon_url | formData | Currency icon | No | string |
| code | formData | Unique currency code. | Yes | string |
| symbol | formData | Currency symbol | Yes | string |
| type | formData | Currency type | No | string |
| base_factor | formData | Currency base factor. | No | integer |
| subunits | formData | Fraction of the basic monetary unit. | No | integer |
| blockchain_key | formData | Associated blockchain key which will perform transactions synchronization for currency. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new currency. | [Currency](#currency) |

### /currencies/{code}

#### GET
##### Description:

Get a currency.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | path | Unique currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a currency. | [Currency](#currency) |

### /currencies

#### GET
##### Description:

Get list of currencies

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| type | query | Currency type | No | string |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of currencies | [ [Currency](#currency) ] |

### /markets/update

#### POST
##### Description:

Update market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| amount_precision | formData | Precision for order amount. | No | integer |
| price_precision | formData | Precision for order price. | No | integer |
| max_price | formData | Maximum order price. | No | double |
| position | formData | Market position. | No | integer |
| state | formData | Market state defines if user can see/trade on current market. | No | string |
| id | formData | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | Yes | string |
| min_price | formData | Minimum order price. | No | double |
| min_amount | formData | Minimum order amount. | No | double |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update market. | [Market](#market) |

### /markets/new

#### POST
##### Description:

Create new market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| amount_precision | formData | Precision for order amount. | No | integer |
| price_precision | formData | Precision for order price. | No | integer |
| max_price | formData | Maximum order price. | No | double |
| position | formData | Market position. | No | integer |
| state | formData | Market state defines if user can see/trade on current market. | No | string |
| base_currency | formData | Market Base unit. | Yes | string |
| quote_currency | formData | Market Quote unit. | Yes | string |
| min_price | formData | Minimum order price. | Yes | double |
| min_amount | formData | Minimum order amount. | Yes | double |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new market. | [Market](#market) |

### /markets/{id}

#### GET
##### Description:

Get market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get market. | [Market](#market) |

### /markets

#### GET
##### Description:

Get all markets, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all markets, result is paginated. | [ [Market](#market) ] |

### /wallets/update

#### POST
##### Description:

Update wallet.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| settings | formData | Wallet settings. | No | json |
| max_balance | formData | Wallet max balance. | No | double |
| status | formData | Wallet status (active/disabled). | No | string |
| id | formData | Unique wallet identifier in database. | Yes | integer |
| blockchain_key | formData | Wallet blockchain key. | No | string |
| name | formData | Wallet name. | No | string |
| address | formData | Wallet address. | No | string |
| kind | formData | Kind of wallet 'deposit','fee','hot','warm' or 'cold'. | No | string |
| gateway | formData | Wallet gateway. | No | string |
| currency | formData | Wallet currency code. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update wallet. | [Wallet](#wallet) |

### /wallets/new

#### POST
##### Description:

Creates new wallet.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| settings | formData | Wallet settings. | No | json |
| max_balance | formData | Wallet max balance. | No | double |
| status | formData | Wallet status (active/disabled). | No | string |
| blockchain_key | formData | Wallet blockchain key. | Yes | string |
| name | formData | Wallet name. | Yes | string |
| address | formData | Wallet address. | Yes | string |
| currency | formData | Wallet currency code. | Yes | string |
| kind | formData | Kind of wallet 'deposit','fee','hot','warm' or 'cold'. | Yes | string |
| gateway | formData | Wallet gateway. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new wallet. | [Wallet](#wallet) |

### /wallets/{id}

#### GET
##### Description:

Get a wallet.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique wallet identifier in database. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a wallet. | [Wallet](#wallet) |

### /wallets/gateways

#### GET
##### Description:

List wallet gateways.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | List wallet gateways. |

### /wallets/kinds

#### GET
##### Description:

List wallet kinds.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | List wallet kinds. |

### /wallets

#### GET
##### Description:

Get all wallets, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| blockchain_key | query | Wallet blockchain key. | No | string |
| kind | query | Kind of wallet 'deposit','fee','hot','warm' or 'cold'. | No | string |
| currency | query | Deposit currency id. | No | string |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all wallets, result is paginated. | [ [Wallet](#wallet) ] |

### /deposits/new

#### POST
##### Description:

Creates new fiat deposit .

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | Deposit member uid. | Yes | string |
| currency | formData | Deposit currency id. | Yes | string |
| amount | formData | Deposit amount. | Yes | double |
| tid | formData | Deposit tid. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new fiat deposit . | [Deposit](#deposit) |

### /deposits/actions

#### POST
##### Description:

Take an action on the deposit.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique deposit id. | Yes | integer |
| action | formData | Valid actions are [:cancel, :reject, :accept, :skip, :dispatch]. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Take an action on the deposit. | [Deposit](#deposit) |

### /deposits

#### GET
##### Description:

Get all deposits, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| state | query | Deposit state. | No | string |
| id | query | Unique deposit id. | No | integer |
| txid | query | Deposit transaction id. | No | string |
| address | query | Deposit blockchain address. | No | string |
| tid | query | Deposit tid. | No | string |
| uid | query | Member UID. | No | string |
| currency | query | Deposit currency id. | No | string |
| type | query | Currency type | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all deposits, result is paginated. | [ [Deposit](#deposit) ] |

### /withdraws/actions

#### POST
##### Description:

Take an action on the withdrawal.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | The withdrawal id. | Yes | integer |
| action | formData | Valid actions are [:submit, :cancel, :accept, :reject, :process, :load, :dispatch, :success, :skip, :fail, :err]. | Yes | string |
| txid | formData | The withdrawal transaction id. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Take an action on the withdrawal. | [Withdraw](#withdraw) |

### /withdraws/{id}

#### GET
##### Description:

Get withdraw by ID.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | The withdrawal id. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get withdraw by ID. | [Withdraw](#withdraw) |

### /withdraws

#### GET
##### Description:

Get all withdraws, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| state | query | The withdrawal state. | No | string |
| account | query | The account code. | No | integer |
| id | query | The withdrawal id. | No | integer |
| txid | query | The withdrawal transaction id. | No | string |
| tid | query | Withdraw tid. | No | string |
| confirmations | query | Number of confirmations. | No | integer |
| rid | query | The beneficiary ID or wallet address on the Blockchain. | No | string |
| uid | query | Member UID. | No | string |
| currency | query | Deposit currency id. | No | string |
| type | query | Currency type | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all withdraws, result is paginated. | [ [Withdraw](#withdraw) ] |

### /trades/{id}

#### GET
##### Description:

Get a trade with detailed information.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Trade ID. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a trade with detailed information. | [Blockchain](#blockchain) |

### /trades

#### GET
##### Description:

Get all trades, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | No | string |
| order_id | query | Unique order id. | No | integer |
| uid | query | Member UID. | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all trades, result is paginated. | [ [Trade](#trade) ] |

### /assets

#### GET
##### Description:

Returns assets as a paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| reference_type | query | The reference type for which operation was created. | No | string |
| rid | query | The unique id of operation's reference, for which operation was created. | No | integer |
| code | query | Opeartion's code. | No | integer |
| currency | query | Deposit currency id. | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns assets as a paginated collection. | [Operation](#operation) |

### /expenses

#### GET
##### Description:

Returns expenses as a paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| reference_type | query | The reference type for which operation was created. | No | string |
| rid | query | The unique id of operation's reference, for which operation was created. | No | integer |
| code | query | Opeartion's code. | No | integer |
| currency | query | Deposit currency id. | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns expenses as a paginated collection. | [Operation](#operation) |

### /revenues

#### GET
##### Description:

Returns revenues as a paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| reference_type | query | The reference type for which operation was created. | No | string |
| rid | query | The unique id of operation's reference, for which operation was created. | No | integer |
| code | query | Opeartion's code. | No | integer |
| currency | query | Deposit currency id. | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns revenues as a paginated collection. | [Operation](#operation) |

### /liabilities

#### GET
##### Description:

Returns liabilities as a paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | query | Member UID. | No | string |
| reference_type | query | The reference type for which operation was created. | No | string |
| rid | query | The unique id of operation's reference, for which operation was created. | No | integer |
| code | query | Opeartion's code. | No | integer |
| currency | query | Deposit currency id. | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns liabilities as a paginated collection. | [Operation](#operation) |

### /members

#### GET
##### Description:

Get all members, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| state | query | Filter order by state. | No | string |
| role | query |  | No | string |
| email | query | Member email. | No | string |
| uid | query | Member UID. | No | string |
| range | query | Date range picker, defaults to 'created'. | No | string |
| from | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities FROM the time will be retrieved. | No | dateTime |
| to | query | An integer represents the seconds elapsed since Unix epoch.If set, only entities BEFORE the time will be retrieved. | No | dateTime |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all members, result is paginated. | [ [Member](#member) ] |

### /trading_fees/delete

#### POST
##### Description:

It deletes trading fees record

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique trading fee table identifier in database. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | It deletes trading fees record | [TradingFee](#tradingfee) |

### /trading_fees/update

#### POST
##### Description:

It updates trading fees record

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique trading fee table identifier in database. | Yes | integer |
| maker | formData | Market maker fee. | No | double |
| taker | formData | Market taker fee. | No | double |
| group | formData | Member group for define maker/taker fee. | No | string |
| market_id | formData | Market id for define maker/taker fee. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | It updates trading fees record | [TradingFee](#tradingfee) |

### /trading_fees/new

#### POST
##### Description:

It creates trading fees record

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| maker | formData | Market maker fee. | Yes | double |
| taker | formData | Market taker fee. | Yes | double |
| group | formData | Member group for define maker/taker fee. | No | string |
| market_id | formData | Market id for define maker/taker fee. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | It creates trading fees record | [TradingFee](#tradingfee) |

### /trading_fees

#### GET
##### Description:

Returns trading_fees table as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| group | query | Member group for define maker/taker fee. | No | string |
| market_id | query | Market id for define maker/taker fee. | No | string |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns trading_fees table as paginated collection | [ [TradingFee](#tradingfee) ] |

### Models


#### Adjustment

Get all adjustments, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique adjustment identifier in database. | No |
| reason | string | Adjustment reason. | No |
| description | string | Adjustment description. | No |
| category | string | Adjustment category | No |
| amount | string | Adjustment amount. | No |
| validator_uid | integer | Unique adjustment validator identifier in database. | No |
| creator_uid | integer | Unique adjustment creator identifier in database. | No |
| currency | string | Adjustment currency ID. | No |
| asset | [Operation](#operation) |  | No |
| liability | [Operation](#operation) |  | No |
| revenue | [Operation](#operation) |  | No |
| expense | [Operation](#operation) |  | No |
| state | string | Adjustment's state. | No |
| asset_account_code | integer | Adjustment asset account code. | No |
| receiving_account_code | string | Adjustment receiving account code. | No |
| receiving_member_uid | string | Adjustment receiving member uid. | No |
| created_at | string | The datetime when operation was created. | No |
| updated_at | string | The datetime when operation was updated. | No |

#### Operation

Returns liabilities as a paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique operation identifier in database. | No |
| code | string | The Account code which this operation related to. | No |
| currency | string | Operation currency ID. | No |
| credit | string | Operation credit amount. | No |
| debit | string | Operation debit amount. | No |
| uid | string | The shared user ID. | No |
| account_kind | string | Operation's account kind (locked or main). | No |
| rid | string | The id of operation reference. | No |
| reference_type | string | The type of operations. | No |
| created_at | string | The datetime when operation was created. | No |

#### Order

Get all orders, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique order id. | No |
| side | string | Either 'sell' or 'buy'. | No |
| ord_type | string | Type of order, either 'limit' or 'market'. | No |
| price | double | Price for each unit. e.g.If you want to sell/buy 1 btc at 3000 usd, the price is '3000.0' | No |
| avg_price | double | Average execution price, average of price in trades. | No |
| state | string | One of 'wait', 'done', or 'cancel'.An order in 'wait' is an active order, waiting fulfillment;a 'done' order is an order fulfilled;'cancel' means the order has been canceled. | No |
| market | string | The market in which the order is placed, e.g. 'btcusd'.All available markets can be found at /api/v2/markets. | No |
| created_at | string | Order create time in iso8601 format. | No |
| updated_at | string | Order updated time in iso8601 format. | No |
| origin_volume | double | The amount user want to sell/buy.An order could be partially executed,e.g. an order sell 5 btc can be matched with a buy 3 btc order,left 2 btc to be sold; in this case the order's volume would be '5.0',its remaining_volume would be '2.0', its executed volume is '3.0'. | No |
| remaining_volume | double | The remaining volume, see 'volume'. | No |
| executed_volume | double | The executed volume, see 'volume'. | No |
| trades_count | integer | Count of trades. | No |
| email | string | The shared user email. | No |
| uid | string | The shared user ID. | No |

#### Blockchain

Get a trade with detailed information.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique blockchain identifier in database. | No |
| key | string | Unique key to identify blockchain. | No |
| name | string | A name to identify blockchain. | No |
| client | string | Integrated blockchain client. | No |
| server | string | Blockchain server url. | No |
| height | integer | The number of blocks preceding a particular block on blockchain. | No |
| explorer_address | string | Blockchain explorer address template. | No |
| explorer_transaction | string | Blockchain explorer transaction template. | No |
| min_confirmations | integer | Minimum number of confirmations. | No |
| status | string | Blockchain status (active/disabled). | No |
| created_at | string | Blockchain created time in iso8601 format. | No |
| updated_at | string | Blockchain updated time in iso8601 format. | No |

#### Currency

Get list of currencies

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| name | string | Currency name | No |
| symbol | string | Currency symbol | No |
| type | string | Currency type | No |
| deposit_enabled | string | Currency deposit possibility status (true/false). | No |
| withdrawal_enabled | string | Currency withdrawal possibility status (true/false). | No |
| deposit_fee | string | Currency deposit fee | No |
| min_deposit_amount | string | Minimal deposit amount | No |
| withdraw_fee | string | Currency withdraw fee | No |
| min_withdraw_amount | string | Minimal withdraw amount | No |
| withdraw_limit_24h | string | Currency 24h withdraw limit | No |
| withdraw_limit_72h | string | Currency 72h withdraw limit | No |
| base_factor | integer | Currency base factor. | No |
| precision | integer | Currency precision. | No |
| icon_url | string | Currency icon | No |
| min_confirmations | string | Number of confirmations required for confirming deposit or withdrawal | No |
| code | string | Unique currency code. | No |
| blockchain_key | string | Associated blockchain key which will perform transactions synchronization for currency. | No |
| min_collection_amount | double | Minimal collection amount. | No |
| position | integer | Currency position. | No |
| visible | string | Currency display status (true/false). | No |
| subunits | integer | Fraction of the basic monetary unit. | No |
| options | json | Currency options. | No |
| created_at | string | Currency created time in iso8601 format. | No |
| updated_at | string | Currency updated time in iso8601 format. | No |

#### Market

Get all markets, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | No |
| name | string | Market name. | No |
| base_unit | string | Market Base unit. | No |
| quote_unit | string | Market Quote unit. | No |
| min_price | double | Minimum order price. | No |
| max_price | double | Maximum order price. | No |
| min_amount | double | Minimum order amount. | No |
| amount_precision | double | Precision for order amount. | No |
| price_precision | double | Precision for order price. | No |
| state | string | Market state defines if user can see/trade on current market. | No |
| position | integer | Market position. | No |
| created_at | string | Market created time in iso8601 format. | No |
| updated_at | string | Market updated time in iso8601 format. | No |

#### Wallet

Get all wallets, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique wallet identifier in database. | No |
| name | string | Wallet name. | No |
| kind | string | Kind of wallet 'deposit','fee','hot','warm' or 'cold'. | No |
| currency | string | Wallet currency code. | No |
| address | string | Wallet address. | No |
| gateway | string | Wallet gateway. | No |
| max_balance | double | Wallet max balance. | No |
| blockchain_key | string | Wallet blockchain key. | No |
| status | string | Wallet status (active/disabled). | No |
| settings | json | Wallet settings. | No |
| created_at | string | Wallet created time in iso8601 format. | No |
| updated_at | string | Wallet updated time in iso8601 format. | No |

#### Deposit

Get all deposits, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique deposit id. | No |
| currency | string | Deposit currency id. | No |
| amount | double | Deposit amount. | No |
| fee | double | Deposit fee. | No |
| txid | string | Deposit transaction id. | No |
| confirmations | integer | Number of deposit confirmations. | No |
| state | string | Deposit state. | No |
| created_at | string | The datetime when deposit was created. | No |
| completed_at | string | The datetime when deposit was completed. | No |
| member | string | The member id. | No |
| uid | string | Deposit member uid. | No |
| email | string | The deposit member email. | No |
| address | string | Deposit blockchain address. | No |
| txout | integer | Deposit blockchain transaction output. | No |
| block_number | integer | Deposit blockchain block number. | No |
| type | string | Deposit type (fiat or coin). | No |
| tid | string | Deposit tid. | No |
| spread | string | Deposit collection spread. | No |
| updated_at | string | The datetime when deposit was updated. | No |

#### Withdraw

Get all withdraws, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | The withdrawal id. | No |
| currency | string | The currency code. | No |
| type | string | The withdrawal type | No |
| sum | double | The withdrawal sum. | No |
| fee | double | The exchange fee. | No |
| blockchain_txid | string | The withdrawal transaction id. | No |
| rid | string | The beneficiary ID or wallet address on the Blockchain. | No |
| state | string | The withdrawal state. | No |
| confirmations | integer | Number of confirmations. | No |
| note | string | Withdraw note. | No |
| created_at | string | The datetimes for the withdrawal. | No |
| updated_at | string | The datetimes for the withdrawal. | No |
| completed_at | string | The datetime when withdraw was completed. | No |
| member | string | The member id. | No |
| beneficiary | [Beneficiary](#beneficiary) |  | No |
| uid | string | The withdrawal member uid. | No |
| email | string | The withdrawal member email. | No |
| account | string | The account code. | No |
| block_number | integer | The withdrawal block_number. | No |
| amount | double | The withdrawal amount. | No |
| tid | string | Withdraw tid. | No |

#### Beneficiary

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Beneficiary Identifier in Database | No |
| currency | string | Beneficiary currency code. | No |
| name | string | Human rememberable name which refer beneficiary. | No |
| description | string | Human rememberable description of beneficiary. | No |
| data | json | Bank Account details for fiat Beneficiary in JSON format.For crypto it's blockchain address. | No |
| state | string | Defines either beneficiary active - user can use it to withdraw moneyor pending - requires beneficiary activation with pin. | No |

#### Trade

Get all trades, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Trade ID. | No |
| price | double | Trade price. | No |
| amount | double | Trade amount. | No |
| total | double | Trade total (Amount * Price). | No |
| market | string | Trade market id. | No |
| created_at | string | Trade create time in iso8601 format. | No |
| taker_type | string | Trade taker order type (sell or buy). | No |
| maker_order_email | string | Trade maker member email. | No |
| maker_uid | string | Trade maker member uid. | No |
| maker_fee | double | Trade maker fee percentage. | No |
| maker_fee_amount | double | Trade maker fee amount. | No |
| maker_fee_currency | string | Trade maker fee currency code. | No |
| maker_order | [Order](#order) |  | No |
| taker_order_email | string | Trade taker member email. | No |
| taker_uid | string | Trade taker member uid. | No |
| taker_fee_currency | string | Trade taker fee currency code. | No |
| taker_fee | double | Trade taker fee percentage. | No |
| taker_fee_amount | double | Trade taker fee amount. | No |
| taker_order | [Order](#order) |  | No |

#### Member

Get all members, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| uid | string | Member UID. | No |
| email | string | Member email. | No |
| accounts | [ [Account](#account) ] | Member accounts. | No |
| id | integer | Unique member identifier in database. | No |
| level | integer | Member's level. | No |
| role | string | Member's role. | No |
| state | string | Member's state. | No |
| created_at | string | Member created time in iso8601 format. | No |
| updated_at | string | Member updated time in iso8601 format. | No |

#### Account

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| currency | string | Currency code. | No |
| balance | double | Account balance. | No |
| locked | double | Account locked funds. | No |

#### TradingFee

Returns trading_fees table as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique trading fee table identifier in database. | No |
| group | string | Member group for define maker/taker fee. | No |
| market_id | string | Market id for define maker/taker fee. | No |
| maker | double | Market maker fee. | No |
| taker | double | Market taker fee. | No |
| created_at | string | Trading fee table created time in iso8601 format. | No |
| updated_at | string | Trading fee table updated time in iso8601 format. | No |