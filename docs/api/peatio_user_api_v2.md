# Peatio User API v2
API for Peatio application.

## Version: 2.2.11

**Contact information:**  
peatio.tech  
https://www.peatio.tech  
hello@peatio.tech  

**License:** https://github.com/rubykube/peatio/blob/master/LICENSE.md

### Security
**Bearer**  

|apiKey|*API Key*|
|---|---|
|Name|JWT|
|In|header|

### /public/health/ready

#### GET
##### Description:

Get application readiness status

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get application readiness status |

### /public/health/alive

#### GET
##### Description:

Get application liveness status

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get application liveness status |

### /public/version

#### GET
##### Description:

Get running Peatio version and build details.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get running Peatio version and build details. |

### /public/timestamp

#### GET
##### Description:

Get server current time, in seconds since Unix epoch.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get server current time, in seconds since Unix epoch. |

### /public/member-levels

#### GET
##### Description:

Returns hash of minimum levels and the privileges they provide.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns hash of minimum levels and the privileges they provide. |

### /public/markets/{market}/tickers

#### GET
##### Description:

Get ticker of specific market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get ticker of specific market. |

### /public/markets/tickers

#### GET
##### Description:

Get ticker of all markets.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get ticker of all markets. |

### /public/markets/{market}/k-line

#### GET
##### Description:

Get OHLC(k line) of specific market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path |  | Yes | string |
| period | query | Time period of K line, default to 1. You can choose between 1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080 | No | integer |
| time_from | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned. | No | integer |
| time_to | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data till that time will be returned. | No | integer |
| limit | query | Limit the number of returned data points default to 30. Ignored if time_from and time_to are given. | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get OHLC(k line) of specific market. |

### /public/markets/{market}/depth

#### GET
##### Description:

Get depth or specified market. Both asks and bids are sorted from highest price to lowest.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path |  | Yes | string |
| limit | query | Limit the number of returned price levels. Default to 300. | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get depth or specified market. Both asks and bids are sorted from highest price to lowest. |

### /public/markets/{market}/trades

#### GET
##### Description:

Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path |  | Yes | string |
| limit | query | Limit the number of returned trades. Default to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| timestamp | query | An integer represents the seconds elapsed since Unix epoch.If set, only trades executed before the time will be returned. | No | integer |
| order_by | query | If set, returned trades will be sorted in specific order, default to 'desc'. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order. | [ [Trade](#trade) ] |

### /public/markets/{market}/order-book

#### GET
##### Description:

Get the order book of specified market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path |  | Yes | string |
| asks_limit | query | Limit the number of returned sell orders. Default to 20. | No | integer |
| bids_limit | query | Limit the number of returned buy orders. Default to 20. | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get the order book of specified market. | [ [OrderBook](#orderbook) ] |

### /public/markets

#### GET
##### Description:

Get all available markets.

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all available markets. | [ [Market](#market) ] |

### /public/currencies

#### GET
##### Description:

Get list of currencies

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| type | query | Currency type | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of currencies | [ [Currency](#currency) ] |

### /public/currencies/{id}

#### GET
##### Description:

Get a currency

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a currency | [Currency](#currency) |

### /account/balances/{currency}

#### GET
##### Description:

Get user account by currency

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | path | The currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get user account by currency | [Account](#account) |

### /account/balances

#### GET
##### Description:

Get list of user accounts

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of user accounts | [ [Account](#account) ] |

### /account/deposit_address/{currency}

#### GET
##### Description:

Returns deposit address for account you want to deposit to by currency. The address may be blank because address generation process is still in progress. If this case you should try again later.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | path | The account you want to deposit to. | Yes | string |
| address_format | query | Address format legacy/cash | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Returns deposit address for account you want to deposit to by currency. The address may be blank because address generation process is still in progress. If this case you should try again later. | [Deposit](#deposit) |

### /account/deposits/{txid}

#### GET
##### Description:

Get details of specific deposit.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| txid | path | Deposit transaction id | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get details of specific deposit. | [Deposit](#deposit) |

### /account/deposits

#### GET
##### Description:

Get your deposits history.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Currency code | No | string |
| state | query |  | No | string |
| limit | query | Number of deposits per page (defaults to 100, maximum is 100). | No | integer |
| page | query | Page number (defaults to 1). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get your deposits history. | [ [Deposit](#deposit) ] |

### /account/withdraws

#### POST
##### Description:

Creates new crypto withdrawal.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| otp | formData | OTP to perform action | Yes | integer |
| rid | formData | Wallet address on the Blockchain. | Yes | string |
| currency | formData | The currency code. | Yes | string |
| amount | formData | The amount to withdraw. | Yes | double |
| note | formData | Optional metadata to be applied to the transaction. Used to tag transactions with memorable comments. | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Creates new crypto withdrawal. |

#### GET
##### Description:

List your withdraws as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Currency code. | No | string |
| limit | query | Number of withdraws per page (defaults to 100, maximum is 100). | No | integer |
| page | query | Page number (defaults to 1). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | List your withdraws as paginated collection. | [ [Withdraw](#withdraw) ] |

### /market/trades

#### GET
##### Description:

Get your executed trades. Trades are sorted in reverse creation order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query |  | No | string |
| limit | query | Limit the number of returned trades. Default to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| time_from | query | An integer represents the seconds elapsed since Unix epoch.If set, only trades executed after the time will be returned. | No | integer |
| time_to | query | An integer represents the seconds elapsed since Unix epoch.If set, only trades executed before the time will be returned. | No | integer |
| order_by | query | If set, returned trades will be sorted in specific order, default to 'desc'. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get your executed trades. Trades are sorted in reverse creation order. | [ [Trade](#trade) ] |

### /market/orders/cancel

#### POST
##### Description:

Cancel all my orders.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | formData |  | No | string |
| side | formData | If present, only sell orders (asks) or buy orders (bids) will be canncelled. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Cancel all my orders. | [Order](#order) |

### /market/orders/{id}/cancel

#### POST
##### Description:

Cancel an order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path |  | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Cancel an order. |

### /market/orders

#### POST
##### Description:

Create a Sell/Buy order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | formData |  | Yes | string |
| side | formData |  | Yes | string |
| volume | formData |  | Yes | double |
| ord_type | formData |  | No | string |
| price | formData |  | Yes | double |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create a Sell/Buy order. | [Order](#order) |

#### GET
##### Description:

Get your orders, results is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query |  | No | string |
| state | query | Filter order by state. | No | string |
| limit | query | Limit the number of returned orders, default to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| order_by | query | If set, returned orders will be sorted in specific order, default to "desc". | No | string |
| ord_type | query | Filter order by ord_type. | No | string |
| type | query | Filter order by type. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get your orders, results is paginated. | [ [Order](#order) ] |

### /market/orders/{id}

#### GET
##### Description:

Get information of specified order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path |  | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get information of specified order. | [Order](#order) |

### Models


#### Trade

Get your executed trades. Trades are sorted in reverse creation order.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Trade ID. | No |
| price | double | Trade price. | No |
| volume | double | Trade volume. | No |
| funds | double | Trade funds. | No |
| market | string | Trade market id. | No |
| created_at | string | Trade create time in iso8601 format. | No |
| taker_type | string | Trade maker order type (sell or buy). | No |
| side | string | Trade side. | No |
| order_id | integer | Order id. | No |

#### OrderBook

Get the order book of specified market.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| asks | [ [Order](#order) ] | Asks in orderbook | No |
| bids | [ [Order](#order) ] | Bids in orderbook | No |

#### Order

Get your orders, results is paginated.

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
| trades | [ [Trade](#trade) ] | Trades wiht this order. | No |

#### Market

Get all available markets.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | No |
| name | string | Market name. | No |
| ask_unit | string | Market ask unit. | No |
| bid_unit | string | Market bid unit. | No |
| ask_fee | double | Market ask fee. | No |
| bid_fee | double | Market bid fee. | No |
| min_ask_price | double | Max ask order price. | No |
| max_bid_price | double | Max bid order price. | No |
| min_ask_amount | double | Min ask order amount. | No |
| min_bid_amount | double | Min bid order amount. | No |
| ask_precision | double | Precision for ask order. | No |
| bid_precision | double | Precision for bid order. | No |

#### Currency

Get a currency

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Currency code. | No |
| name | string | Currency name | No |
| symbol | string | Currency symbol | No |
| explorer_transaction | string | Currency transaction exprorer url template | No |
| explorer_address | string | Currency address exprorer url template | No |
| type | string | Currency type | No |
| deposit_fee | string | Currency deposit fee | No |
| min_deposit_amount | string | Minimal deposit amount | No |
| withdraw_fee | string | Currency withdraw fee | No |
| min_withdraw_amount | string | Minimal withdraw amount | No |
| withdraw_limit_24h | string | Currency 24h withdraw limit | No |
| withdraw_limit_72h | string | Currency 72h withdraw limit | No |
| base_factor | string | Currency base factor | No |
| precision | string | Currency precision | No |
| icon_url | string | Currency icon | No |

#### Account

Get list of user accounts

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| currency | string | Currency code. | No |
| balance | double | Account balance. | No |
| locked | double | Account locked funds. | No |

#### Deposit

Get your deposits history.

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
| completed_at | string | The datetime when deposit was completed.. | No |

#### Withdraw

List your withdraws as paginated collection.

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
| created_at | string | The datetimes for the withdrawal. | No |
| updated_at | string | The datetimes for the withdrawal. | No |
| done_at | string | The datetime when withdraw was completed | No |

#### Member

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| uid | string | Member UID. | No |
| email | string | Member email. | No |
| accounts | [ [Account](#account) ] | Member accounts. | No |