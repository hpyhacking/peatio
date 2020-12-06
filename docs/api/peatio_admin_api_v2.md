# Peatio Admin API v2
Admin API high privileged API with RBAC.

## Version: 2.6.0

**Contact information:**  
openware.com  
<https://www.openware.com>
hello@openware.com  

**License:** <https://github.com/openware/peatio/blob/master/LICENSE.md>

### /api/v2/admin/peatio/blockchains/process_block

#### POST
##### Description

Process blockchain's block.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique blockchain identifier in database. | Yes | integer |
| block_number | formData | The id of a particular block on blockchain | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Process blockchain's block. | [Blockchain](#blockchain) |

### /api/v2/admin/peatio/blockchains/update

#### POST
##### Description

Update blockchain.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique blockchain identifier in database. | Yes | integer |
| key | formData | Unique key to identify blockchain. | No | string |
| name | formData | A name to identify blockchain. | No | string |
| client | formData | Integrated blockchain client. | No | string |
| server | formData | Blockchain server url | No | string |
| height | formData | The number of blocks preceding a particular block on blockchain. | No | integer |
| explorer_transaction | formData | Blockchain explorer transaction template. | No | string |
| explorer_address | formData | Blockchain explorer address template. | No | string |
| status | formData | Blockchain status (active/disabled). | No | string |
| min_confirmations | formData | Minimum number of confirmations. | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update blockchain. | [Blockchain](#blockchain) |

### /api/v2/admin/peatio/blockchains/new

#### POST
##### Description

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
| server | formData | Blockchain server url | No | string |
| status | formData | Blockchain status (active/disabled). | No | string |
| min_confirmations | formData | Minimum number of confirmations. | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new blockchain. | [Blockchain](#blockchain) |

### /api/v2/admin/peatio/blockchains/{id}/latest_block

#### GET
##### Description

Get a latest blockchain block.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique blockchain identifier in database. | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get a latest blockchain block. |

### /api/v2/admin/peatio/blockchains/{id}

#### GET
##### Description

Get a blockchain.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique blockchain identifier in database. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a blockchain. | [Blockchain](#blockchain) |

### /api/v2/admin/peatio/blockchains/clients

#### GET
##### Description

Get available blockchain clients.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get available blockchain clients. |

### /api/v2/admin/peatio/blockchains

#### GET
##### Description

Get all blockchains, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | query | Unique key to identify blockchain. | No | string |
| client | query | Integrated blockchain client. | No | string |
| status | query | Blockchain status (active/disabled). | No | string |
| name | query | A name to identify blockchain. | No | string |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all blockchains, result is paginated. | [ [Blockchain](#blockchain) ] |

### /api/v2/admin/peatio/adjustments/action

#### POST
##### Description

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

### /api/v2/admin/peatio/adjustments/new

#### POST
##### Description

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

### /api/v2/admin/peatio/adjustments/{id}

#### GET
##### Description

Get adjustment by ID

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Adjsustment Identifier in Database | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get adjustment by ID | [Adjustment](#adjustment) |

### /api/v2/admin/peatio/adjustments

#### GET
##### Description

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

### /api/v2/admin/peatio/beneficiaries/actions

#### POST
##### Description

Take an action on the beneficiary

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Beneficiary Identifier in Database | Yes | integer |
| action | formData | Valid actions are [:activate, :archive]. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Take an action on the beneficiary | [Beneficiary](#beneficiary) |

### /api/v2/admin/peatio/beneficiaries

#### GET
##### Description

Get list of beneficiaries

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | query | Member UID. | No | string |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| id | query | Beneficiary Identifier in Database | No | integer |
| currency | query | Beneficiary currency code | No | string |
| state | formData | Beneficiary state | No | [ integer ] |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of beneficiaries | [Beneficiary](#beneficiary) |

### /api/v2/admin/peatio/abilities

#### GET
##### Description

Get all roles and permissions.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get all roles and permissions. |

### /api/v2/admin/peatio/orders/cancel

#### POST
##### Description

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

### /api/v2/admin/peatio/orders/{id}/cancel

#### POST
##### Description

Cancel an order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique order id. | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Cancel an order. |

### /api/v2/admin/peatio/orders

#### GET
##### Description

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

### /api/v2/admin/peatio/currencies/update

#### POST
##### Description

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
| options | formData | Currency options. | No | json |
| visible | formData | Currency display status (true/false). | No | Boolean |
| deposit_enabled | formData | Currency deposit possibility status (true/false). | No | Boolean |
| withdrawal_enabled | formData | Currency withdrawal possibility status (true/false). | No | Boolean |
| precision | formData | Currency precision. | No | integer |
| icon_url | formData | Currency icon | No | string |
| description | formData | Currency description | No | string |
| homepage | formData | Currency homepage | No | string |
| code | formData | Unique currency code. | Yes | string |
| position | formData | Currency position. | No | integer |
| blockchain_key | formData | Associated blockchain key which will perform transactions synchronization for currency. | No | string |
| parent_id | formData | Parent currency id. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update currency. | [Currency](#currency) |

### /api/v2/admin/peatio/currencies/new

#### POST
##### Description

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
| options | formData | Currency options. | No | json |
| visible | formData | Currency display status (true/false). | No | Boolean |
| deposit_enabled | formData | Currency deposit possibility status (true/false). | No | Boolean |
| withdrawal_enabled | formData | Currency withdrawal possibility status (true/false). | No | Boolean |
| precision | formData | Currency precision. | No | integer |
| icon_url | formData | Currency icon | No | string |
| description | formData | Currency description | No | string |
| homepage | formData | Currency homepage | No | string |
| code | formData | Unique currency code. | Yes | string |
| type | formData | Currency type | No | string |
| base_factor | formData | Currency base factor. | No | integer |
| position | formData | Currency position. | No | integer |
| subunits | formData | Fraction of the basic monetary unit. | No | integer |
| blockchain_key | formData | Associated blockchain key which will perform transactions synchronization for currency. | No | string |
| parent_id | formData | Parent currency id. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new currency. | [Currency](#currency) |

### /api/v2/admin/peatio/currencies/{code}

#### GET
##### Description

Get a currency.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | path | Unique currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a currency. | [Currency](#currency) |

### /api/v2/admin/peatio/currencies

#### GET
##### Description

Get list of currencies

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| type | query | Currency type | No | string |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| deposit_enabled | query | Currency deposit possibility status (true/false). | No | Boolean |
| withdrawal_enabled | query | Currency withdrawal possibility status (true/false). | No | Boolean |
| visible | query | Currency display status (true/false). | No | Boolean |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of currencies | [ [Currency](#currency) ] |

### /api/v2/admin/peatio/markets/update

#### POST
##### Description

Update market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| amount_precision | formData | Precision for order amount. | No | integer |
| price_precision | formData | Precision for order price. | No | integer |
| max_price | formData | Maximum order price. | No | double |
| data | formData | Market additional data. | No | json |
| state | formData | Market state defines if user can see/trade on current market. | No | string |
| id | formData | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | Yes | string |
| engine_id | formData | Engine id for this market. | No | integer |
| position | formData | Market position. | No | integer |
| min_price | formData | Minimum order price. | No | double |
| min_amount | formData | Minimum order amount. | No | double |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update market. | [Market](#market) |

### /api/v2/admin/peatio/markets/new

#### POST
##### Description

Create new market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| amount_precision | formData | Precision for order amount. | No | integer |
| price_precision | formData | Precision for order price. | No | integer |
| max_price | formData | Maximum order price. | No | double |
| data | formData | Market additional data. | No | json |
| state | formData | Market state defines if user can see/trade on current market. | No | string |
| base_currency | formData | Market Base unit. | Yes | string |
| quote_currency | formData | Market Quote unit. | Yes | string |
| min_price | formData | Minimum order price. | Yes | double |
| min_amount | formData | Minimum order amount. | Yes | double |
| engine_id | formData | Engine id for this market. | No | integer |
| position | formData | Market position. | No | integer |
| engine_name | formData | Engine name | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new market. | [Market](#market) |

### /api/v2/admin/peatio/markets/{id}

#### GET
##### Description

Get market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get market. | [Market](#market) |

### /api/v2/admin/peatio/markets

#### GET
##### Description

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

### /api/v2/admin/peatio/wallets/currencies

#### DELETE
##### Description

Delete currency from the wallet

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | query | Unique wallet identifier in database. | Yes | integer |
| currencies | query | Wallet currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Delete currency from the wallet | [Wallet](#wallet) |

#### POST
##### Description

Add currency to the wallet

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique wallet identifier in database. | Yes | integer |
| currencies | formData | Wallet currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Add currency to the wallet | [Wallet](#wallet) |

### /api/v2/admin/peatio/wallets/update

#### POST
##### Description

Update wallet.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| max_balance | formData | Wallet max balance. | No | double |
| status | formData | Wallet status (active/disabled). | No | string |
| id | formData | Unique wallet identifier in database. | Yes | integer |
| blockchain_key | formData | Wallet blockchain key. | No | string |
| name | formData | Wallet name. | No | string |
| address | formData | Wallet address. | No | string |
| kind | formData | Kind of wallet 'deposit','fee','hot','warm' or 'cold'. | No | string |
| gateway | formData | Wallet gateway. | No | string |
| currencies | formData | Wallet currency code. | No | string |
| settings | formData | Wallet settings | No | json |
| settings[uri] | formData | Wallet uri setting | No | string |
| settings[secret] | formData | Wallet secret setting | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update wallet. | [Wallet](#wallet) |

### /api/v2/admin/peatio/wallets/new

#### POST
##### Description

Creates new wallet.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| max_balance | formData | Wallet max balance. | No | double |
| status | formData | Wallet status (active/disabled). | No | string |
| blockchain_key | formData | Wallet blockchain key. | Yes | string |
| name | formData | Wallet name. | Yes | string |
| address | formData | Wallet address. | No | string |
| currencies | formData | Wallet currency code. | No | string |
| currency | formData | Wallet currency code. | No | string |
| kind | formData | Kind of wallet 'deposit','fee','hot','warm' or 'cold'. | Yes | string |
| gateway | formData | Wallet gateway. | Yes | string |
| settings | formData | Wallet settings (uri, secret) | No | json |
| settings[uri] | formData | Wallet uri setting | No | string |
| settings[secret] | formData | Wallet secret setting | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new wallet. | [Wallet](#wallet) |

### /api/v2/admin/peatio/wallets/{id}

#### GET
##### Description

Get a wallet.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique wallet identifier in database. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a wallet. | [Wallet](#wallet) |

### /api/v2/admin/peatio/wallets/gateways

#### GET
##### Description

List wallet gateways.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | List wallet gateways. |

### /api/v2/admin/peatio/wallets/kinds

#### GET
##### Description

List wallet kinds.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | List wallet kinds. |

### /api/v2/admin/peatio/wallets

#### GET
##### Description

Get all wallets, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| blockchain_key | query | Wallet blockchain key. | No | string |
| kind | query | Kind of wallet 'deposit','fee','hot','warm' or 'cold'. | No | string |
| currencies | query | Wallet currency code. | No | string |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all wallets, result is paginated. | [ [Wallet](#wallet) ] |

### /api/v2/admin/peatio/deposits/{id}/refund

#### POST
##### Description

Creates new crypto refund

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Deposit id | Yes | integer |
| address | formData | Refund address | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new crypto refund | [Refund](#refund) |

### /api/v2/admin/peatio/deposits/new

#### POST
##### Description

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

### /api/v2/admin/peatio/deposits/actions

#### POST
##### Description

Take an action on the deposit.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique deposit id. | Yes | integer |
| action | formData | Valid actions are [:cancel, :reject, :accept, :skip, :process, :fee_process, :dispatch, :refund]. | Yes | string |
| fees | formData | Process deposit collection with collecting fees or not | No | Boolean |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Take an action on the deposit. | [Deposit](#deposit) |

### /api/v2/admin/peatio/deposits

#### GET
##### Description

Get all deposits, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| state | query | Deposit state. | No | string |
| id | query | Unique deposit id. | No | integer |
| txid | query | Deposit transaction id. | No | string |
| address | query | Deposit blockchain address. | No | string |
| tid | query | Deposit tid. | No | string |
| email | query | The deposit member email. | No | string |
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

### /api/v2/admin/peatio/deposit_address

#### POST
##### Description

Returns deposit address for account you want to deposit to by currency and uid.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | Deposit member uid. | Yes | string |
| currency | formData | Deposit currency id. | Yes | string |
| address_format | formData | Address format legacy/cash | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns deposit address for account you want to deposit to by currency and uid. | [Deposit](#deposit) |

### /api/v2/admin/peatio/withdraws

#### PUT
##### Description

Update withdraw request

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | The withdrawal id. | Yes | integer |
| metadata | formData | Optional metadata to be applied to the transaction. | No | json |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update withdraw request | [Withdraw](#withdraw) |

#### GET
##### Description

Get all withdraws, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| state | query | The withdrawal state. | No | string |
| id | query | The withdrawal id. | No | integer |
| txid | query | The withdrawal transaction id. | No | string |
| tid | query | Withdraw tid. | No | string |
| confirmations | query | Number of confirmations. | No | integer |
| rid | query | The beneficiary ID or wallet address on the Blockchain. | No | string |
| wallet_type | query | Select withdraw that can be processed from wallets with given type e.g. patiry | No | string |
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

### /api/v2/admin/peatio/withdraws/actions

#### POST
##### Description

Take an action on the withdrawal.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | The withdrawal id. | Yes | integer |
| action | formData | Valid actions are [:accept, :cancel, :reject, :process, :load, :dispatch, :success, :skip, :fail, :err]. | Yes | string |
| txid | formData | The withdrawal transaction id. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Take an action on the withdrawal. | [Withdraw](#withdraw) |

### /api/v2/admin/peatio/withdraws/{id}

#### GET
##### Description

Get withdraw by ID.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | The withdrawal id. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get withdraw by ID. | [Withdraw](#withdraw) |

### /api/v2/admin/peatio/trades/{id}

#### GET
##### Description

Get a trade with detailed information.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Trade ID. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a trade with detailed information. | [Blockchain](#blockchain) |

### /api/v2/admin/peatio/trades

#### GET
##### Description

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

### /api/v2/admin/peatio/assets

#### GET
##### Description

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

### /api/v2/admin/peatio/expenses

#### GET
##### Description

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

### /api/v2/admin/peatio/revenues

#### GET
##### Description

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

### /api/v2/admin/peatio/liabilities

#### GET
##### Description

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

### /api/v2/admin/peatio/members/{uid}

#### PUT
##### Description

Set user group.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | path | The shared user ID. | Yes | string |
| group | formData | User gruop | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Set user group. | [Member](#member) |

#### GET
##### Description

Get a member.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | path | The shared user ID. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a member. | [Member](#member) |

### /api/v2/admin/peatio/members/groups

#### GET
##### Description

Get available members groups.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get available members groups. |

### /api/v2/admin/peatio/members

#### GET
##### Description

Get all members, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| state | query | Filter order by state. | No | string |
| role | query |  | No | string |
| group | query |  | No | string |
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

### /api/v2/admin/peatio/trading_fees/delete

#### POST
##### Description

It deletes trading fees record

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique trading fee table identifier in database. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | It deletes trading fees record | [TradingFee](#tradingfee) |

### /api/v2/admin/peatio/trading_fees/update

#### POST
##### Description

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

### /api/v2/admin/peatio/trading_fees/new

#### POST
##### Description

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

### /api/v2/admin/peatio/trading_fees

#### GET
##### Description

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

### /api/v2/admin/peatio/engines/update

#### POST
##### Description

Update engine

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Engine uniq id | Yes | string |
| name | formData | Engine name | No | string |
| driver | formData | Engine driver | No | string |
| key | formData | Credentials for remote engine | No | string |
| secret | formData | Credentials for remote engine | No | string |
| state | formData | Engine state | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Update engine | [Engine](#engine) |

### /api/v2/admin/peatio/engines/new

#### POST
##### Description

Create new engine.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| name | formData | Engine name | Yes | string |
| driver | formData | Engine driver | Yes | string |
| uid | formData | Owner of a engine | No | string |
| key | formData | Credentials for remote engine | No | string |
| secret | formData | Credentials for remote engine | No | string |
| data | formData | Metadata for engine | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new engine. | [Engine](#engine) |

### /api/v2/admin/peatio/engines/{id}

#### GET
##### Description

Get engine.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Engine uniq id | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get engine. | [Engine](#engine) |

### /api/v2/admin/peatio/engines

#### GET
##### Description

Get all engine, result is paginated.

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
| 200 | Get all engine, result is paginated. | [ [Engine](#engine) ] |

### /api/v2/admin/peatio/withdraw_limits/{id}

#### DELETE
##### Description

It deletes withdraw limits record

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique withdraw limit table identifier in database. | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | It deletes withdraw limits record | [WithdrawLimit](#withdrawlimit) |

### /api/v2/admin/peatio/withdraw_limits

#### PUT
##### Description

It updates withdraw limits record

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique withdraw limit table identifier in database. | Yes | integer |
| limit_24_hour | formData | 24 hours withdraw limit. | No | double |
| limit_1_month | formData | 1 month withdraw limit. | No | double |
| kyc_level | formData | KYC level for define withdraw limits. | No | string |
| group | formData | Member group for define withdraw limits. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | It updates withdraw limits record | [WithdrawLimit](#withdrawlimit) |

#### POST
##### Description

It creates withdraw limits record

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| limit_24_hour | formData | 24 hours withdraw limit. | Yes | double |
| limit_1_month | formData | 1 month withdraw limit. | Yes | double |
| group | formData | Member group for define withdraw limits. | No | string |
| kyc_level | formData | KYC level for define withdraw limits. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | It creates withdraw limits record | [WithdrawLimit](#withdrawlimit) |

#### GET
##### Description

Returns withdraw limits table as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| group | query | Member group for define withdraw limits. | No | string |
| kyc_level | query | KYC level for define withdraw limits. | No | string |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns withdraw limits table as paginated collection | [ [WithdrawLimit](#withdrawlimit) ] |

### Models

#### Blockchain

Get a trade with detailed information.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique blockchain identifier in database. | No |
| key | string | Unique key to identify blockchain. | No |
| name | string | A name to identify blockchain. | No |
| client | string | Integrated blockchain client. | No |
| height | integer | The number of blocks preceding a particular block on blockchain. | No |
| explorer_address | string | Blockchain explorer address template. | No |
| explorer_transaction | string | Blockchain explorer transaction template. | No |
| min_confirmations | integer | Minimum number of confirmations. | No |
| status | string | Blockchain status (active/disabled). | No |
| created_at | string | Blockchain created time in iso8601 format. | No |
| updated_at | string | Blockchain updated time in iso8601 format. | No |

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

#### Beneficiary

Get list of beneficiaries

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Beneficiary Identifier in Database | No |
| currency | string | Beneficiary currency code. | No |
| uid | string | Beneficiary owner | No |
| name | string | Human rememberable name which refer beneficiary. | No |
| description | string | Human rememberable description of beneficiary. | No |
| data | json | Bank Account details for fiat Beneficiary in JSON format.For crypto it's blockchain address. | No |
| state | string | Defines either beneficiary active - user can use it to withdraw moneyor pending - requires beneficiary activation with pin. | No |
| sent_at | string | Time when last pin was sent | No |

#### Order

Get all orders, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique order id. | No |
| uuid | string | Unique order UUID. | No |
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
| maker_fee | double | Fee for maker. | No |
| taker_fee | double | Fee for taker. | No |
| trades_count | integer | Count of trades. | No |
| email | string | The shared user email. | No |
| uid | string | The shared user ID. | No |

#### Currency

Get list of currencies

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| name | string | Currency name<br>_Example:_ `"Bitcoin"` | No |
| description | string | Currency description<br>_Example:_ `"btc"` | No |
| homepage | string | Currency homepage<br>_Example:_ `"btc"` | No |
| price | string | Currency current price | No |
| explorer_transaction | string | Currency transaction exprorer url template<br>_Example:_ `"https://testnet.blockchain.info/tx/"` | No |
| explorer_address | string | Currency address exprorer url template<br>_Example:_ `"https://testnet.blockchain.info/address/"` | No |
| type | string | Currency type<br>_Example:_ `"coin"` | No |
| deposit_enabled | string | Currency deposit possibility status (true/false). | No |
| withdrawal_enabled | string | Currency withdrawal possibility status (true/false). | No |
| deposit_fee | string | Currency deposit fee<br>_Example:_ `"0.0"` | No |
| min_deposit_amount | string | Minimal deposit amount<br>_Example:_ `"0.0000356"` | No |
| withdraw_fee | string | Currency withdraw fee<br>_Example:_ `"0.0"` | No |
| min_withdraw_amount | string | Minimal withdraw amount<br>_Example:_ `"0.0"` | No |
| withdraw_limit_24h | string | Currency 24h withdraw limit<br>_Example:_ `"0.1"` | No |
| withdraw_limit_72h | string | Currency 72h withdraw limit<br>_Example:_ `"0.2"` | No |
| base_factor | integer | Currency base factor. | No |
| precision | integer | Currency precision. | No |
| position | integer | Currency position. | No |
| icon_url | string | Currency icon<br>_Example:_ `"https://upload.wikimedia.org/wikipedia/commons/0/05/Ethereum_logo_2014.svg"` | No |
| min_confirmations | string | Number of confirmations required for confirming deposit or withdrawal | No |
| code | string | Unique currency code. | No |
| blockchain_key | string | Associated blockchain key which will perform transactions synchronization for currency. | No |
| parent_id | string | Parent currency id. | No |
| min_collection_amount | double | Minimal collection amount. | No |
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
| engine_id | integer | Engine id for this market. | No |
| position | integer | Market position. | No |
| data | json | Market additional data. | No |
| created_at | string | Market created time in iso8601 format. | No |
| updated_at | string | Market updated time in iso8601 format. | No |

#### Wallet

Get all wallets, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique wallet identifier in database. | No |
| name | string | Wallet name. | No |
| kind | string | Kind of wallet 'deposit','fee','hot','warm' or 'cold'. | No |
| currencies | [ string ] | Wallet currency code. | No |
| address | string | Wallet address. | No |
| gateway | string | Wallet gateway. | No |
| max_balance | double | Wallet max balance. | No |
| balance | double | Wallet balance | No |
| blockchain_key | string | Wallet blockchain key. | No |
| status | string | Wallet status (active/disabled). | No |
| created_at | string | Wallet created time in iso8601 format. | No |
| updated_at | string | Wallet updated time in iso8601 format. | No |

#### Refund

Creates new crypto refund

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | The refund id | No |
| address | string | Refund address | No |
| deposit | [Deposit](#deposit) |  | No |

#### Deposit

Returns deposit address for account you want to deposit to by currency and uid.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique deposit id. | No |
| currency | string | Deposit currency id. | No |
| amount | double | Deposit amount. | No |
| fee | double | Deposit fee. | No |
| txid | string | Deposit transaction id. | No |
| confirmations | integer | Number of deposit confirmations. | No |
| state | string | Deposit state. | No |
| transfer_type | string | Deposit transfer type | No |
| created_at | string | The datetime when deposit was created. | No |
| completed_at | string | The datetime when deposit was completed. | No |
| tid | string | Deposit tid. | No |
| member | string | The member id. | No |
| uid | string | Deposit member uid. | No |
| email | string | The deposit member email. | No |
| address | string | Deposit blockchain address. | No |
| txout | integer | Deposit blockchain transaction output. | No |
| block_number | integer | Deposit blockchain block number. | No |
| type | string | Deposit type (fiat or coin). | No |
| spread | string | Deposit collection spread. | No |
| updated_at | string | The datetime when deposit was updated. | No |

#### Withdraw

Get all withdraws, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | The withdrawal id. | No |
| currency | string | The currency code. | No |
| type | string | The withdrawal type | No |
| amount | string | The withdrawal amount | No |
| fee | double | The exchange fee. | No |
| blockchain_txid | string | The withdrawal transaction id. | No |
| rid | string | The beneficiary ID or wallet address on the Blockchain. | No |
| state | string | The withdrawal state. | No |
| confirmations | integer | Number of confirmations. | No |
| note | string | Withdraw note. | No |
| transfer_type | string | Withdraw transfer type | No |
| created_at | string | The datetimes for the withdrawal. | No |
| updated_at | string | The datetimes for the withdrawal. | No |
| done_at | string | The datetime when withdraw was completed | No |
| member | string | The member id. | No |
| beneficiary | [Beneficiary](#beneficiary) |  | No |
| uid | string | The withdrawal member uid. | No |
| email | string | The withdrawal member email. | No |
| account | string | The account code. | No |
| block_number | integer | The withdrawal block_number. | No |
| tid | string | Withdraw tid. | No |
| error | string | Withdraw error. | No |
| metadata | string | Optional metadata to be applied to the transaction. | No |

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
| group | string | Member's group. | No |
| state | string | Member's state. | No |
| created_at | string | Member created time in iso8601 format. | No |
| updated_at | string | Member updated time in iso8601 format. | No |
| beneficiaries | [ [Beneficiary](#beneficiary) ] | Member Beneficiary. | No |

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

#### Engine

Get all engine, result is paginated.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Engine uniq id | No |
| name | string | Engine name | No |
| driver | string | Engine driver | No |
| uid | string | Owner of a engine | No |
| state | string | Engine state | No |

#### WithdrawLimit

Returns withdraw limits table as paginated collection

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique withdraw limit table identifier in database. | No |
| group | string | Member group for define withdraw limits. | No |
| kyc_level | string | KYC level for define withdraw limits. | No |
| limit_24_hour | double | 24 hours withdraw limit. | No |
| limit_1_month | double | 1 month withdraw limit. | No |
| created_at | string | Withdraw limit table created time in iso8601 format. | No |
| updated_at | string | Withdraw limit table updated time in iso8601 format. | No |
