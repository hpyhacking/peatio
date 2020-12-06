# Peatio User API v2
API for Peatio application.

## Version: 2.6.0

**Contact information:**  
openware.com  
<https://www.openware.com>
hello@openware.com  

**License:** <https://github.com/openware/peatio/blob/master/LICENSE.md>

### Security
**Bearer**  

|apiKey|*API Key*|
|---|---|
|Name|JWT|
|In|header|

### /api/v2/peatio/public/withdraw_limits

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

### /api/v2/peatio/public/webhooks/{event}

#### POST
##### Description

Bitgo Webhook

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| event | path | Name of event can be deposit or withdraw | Yes | string |
| type | formData | Type of event. | Yes | string |
| hash | formData | Address txid. | Yes | string |
| transfer | formData | Transfer id. | Yes | string |
| coin | formData | Currency code. | Yes | string |
| wallet | formData | Wallet id. | Yes | string |
| address | formData | User Address. | Yes | string |
| walletId | formData | Wallet id. | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Bitgo Webhook |

### /api/v2/peatio/public/trading_fees

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

### /api/v2/peatio/public/health/ready

#### GET
##### Description

Get application readiness status

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get application readiness status |

### /api/v2/peatio/public/health/alive

#### GET
##### Description

Get application liveness status

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get application liveness status |

### /api/v2/peatio/public/version

#### GET
##### Description

Get running Peatio version and build details.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get running Peatio version and build details. |

### /api/v2/peatio/public/timestamp

#### GET
##### Description

Get server current time, in seconds since Unix epoch.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get server current time, in seconds since Unix epoch. |

### /api/v2/peatio/public/member-levels

#### GET
##### Description

Returns hash of minimum levels and the privileges they provide.

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns hash of minimum levels and the privileges they provide. |

### /api/v2/peatio/public/markets/{market}/tickers

#### GET
##### Description

Get ticker of specific market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path |  | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get ticker of specific market. | [Ticker](#ticker) |

### /api/v2/peatio/public/markets/tickers

#### GET
##### Description

Get ticker of all markets (For response doc see /:market/tickers/ response).

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get ticker of all markets (For response doc see /:market/tickers/ response). | [Ticker](#ticker) |

### /api/v2/peatio/public/markets/{market}/k-line

#### GET
##### Description

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

### /api/v2/peatio/public/markets/{market}/depth

#### GET
##### Description

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

### /api/v2/peatio/public/markets/{market}/trades

#### GET
##### Description

Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path |  | Yes | string |
| limit | query | Limit the number of returned trades. Default to 100. | No | integer |
| timestamp | query | An integer represents the seconds elapsed since Unix epoch.If set, only trades executed before the time will be returned. | No | integer |
| order_by | query | If set, returned trades will be sorted in specific order, default to 'desc'. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order. | [ [Trade](#trade) ] |

### /api/v2/peatio/public/markets/{market}/order-book

#### GET
##### Description

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

### /api/v2/peatio/public/markets

#### GET
##### Description

Get all available markets.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| ordering | query | If set, returned values will be sorted in specific order, defaults to 'asc'. | No | string |
| order_by | query | Name of the field, which result will be ordered by. | No | string |
| base_unit | query | Strict filter for base unit | No | string |
| quote_unit | query | Strict filter for quote unit | No | string |
| search | query |  | No | json |
| search[base_code] | query | Search base currency code using LIKE | No | string |
| search[quote_code] | query | Search qoute currency code using LIKE | No | string |
| search[base_name] | query | Search base currency name using LIKE | No | string |
| search[quote_name] | query | Search quote currency name using LIKE | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get all available markets. | [ [Market](#market) ] |

### /api/v2/peatio/public/currencies

#### GET
##### Description

Get list of currencies

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| type | query | Currency type | No | string |
| search | query |  | No | json |
| search[code] | query | Search by currency code using SQL LIKE | No | string |
| search[name] | query | Search by currency name using SQL LIKE | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of currencies | [ [Currency](#currency) ] |

### /api/v2/peatio/public/currencies/{id}

#### GET
##### Description

Get a currency

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a currency | [Currency](#currency) |

### /api/v2/peatio/account/stats/pnl

#### GET
##### Description

Get assets pnl calculated into one currency

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| pnl_currency | query | Currency code in which the PnL is calculated | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get assets pnl calculated into one currency |

### /api/v2/peatio/account/transactions

#### GET
##### Description

Get your transactions history.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Currency code | No | string |
| order_by | query | Sorting order | No | string |
| time_from | query | An integer represents the seconds elapsed since Unix epoch. | No | integer |
| time_to | query | An integer represents the seconds elapsed since Unix epoch. | No | integer |
| deposit_state | query | Filter deposits by states. | No | string |
| withdraw_state | query | Filter withdraws by states. | No | string |
| txid | query | Transaction id. | No | string |
| limit | query | Limit the number of returned transactions. Default to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get your transactions history. |

### /api/v2/peatio/account/withdraws

#### POST
##### Description

Creates new withdrawal to active beneficiary.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| otp | formData | OTP to perform action | Yes | integer |
| beneficiary_id | formData | ID of Active Beneficiary belonging to user. | Yes | integer |
| currency | formData | The currency code. | Yes | string |
| amount | formData | The amount to withdraw. | Yes | double |
| note | formData | Optional user metadata to be applied to the transaction. Used to tag transactions with memorable comments. | No | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Creates new withdrawal to active beneficiary. |

#### GET
##### Description

List your withdraws as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Currency code. | No | string |
| limit | query | Number of withdraws per page (defaults to 100, maximum is 100). | No | integer |
| state | query | Filter withdrawals by states. | No | string |
| rid | query | Wallet address on the Blockchain. | No | string |
| page | query | Page number (defaults to 1). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | List your withdraws as paginated collection. | [ [Withdraw](#withdraw) ] |

### /api/v2/peatio/account/withdraws/sums

#### GET
##### Description

Returns withdrawal sums for last 4 hours and 1 month

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Returns withdrawal sums for last 4 hours and 1 month |

### /api/v2/peatio/account/beneficiaries/{id}

#### DELETE
##### Description

Delete beneficiary

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Beneficiary Identifier in Database | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 204 | Delete beneficiary |

#### GET
##### Description

Get beneficiary by ID

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Beneficiary Identifier in Database | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get beneficiary by ID | [Beneficiary](#beneficiary) |

### /api/v2/peatio/account/beneficiaries/{id}/activate

#### PATCH
##### Description

Activates beneficiary with pin

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Beneficiary Identifier in Database | Yes | integer |
| pin | formData | Pin code for beneficiary activation | Yes | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Activates beneficiary with pin | [Beneficiary](#beneficiary) |

### /api/v2/peatio/account/beneficiaries/{id}/resend_pin

#### PATCH
##### Description

Resend beneficiary pin

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Beneficiary Identifier in Database | Yes | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Resend beneficiary pin |

### /api/v2/peatio/account/beneficiaries

#### POST
##### Description

Create new beneficiary

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | Beneficiary currency code. | Yes | string |
| name | formData | Human rememberable name which refer beneficiary. | Yes | string |
| description | formData | Human rememberable name which refer beneficiary. | No | string |
| data | formData | Beneficiary data in JSON format | Yes | json |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new beneficiary | [Beneficiary](#beneficiary) |

#### GET
##### Description

Get list of user beneficiaries

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Beneficiary currency code. | No | string |
| state | query | Defines either beneficiary active - user can use it to withdraw moneyor pending - requires beneficiary activation with pin. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of user beneficiaries | [ [Beneficiary](#beneficiary) ] |

### /api/v2/peatio/account/deposit_address/{currency}

#### GET
##### Description

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

### /api/v2/peatio/account/deposits/{txid}

#### GET
##### Description

Get details of specific deposit.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| txid | path | Deposit transaction id | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get details of specific deposit. | [Deposit](#deposit) |

### /api/v2/peatio/account/deposits

#### GET
##### Description

Get your deposits history.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Currency code | No | string |
| state | query | Filter deposits by states. | No | string |
| txid | query | Deposit transaction id. | No | string |
| limit | query | Number of deposits per page (defaults to 100, maximum is 100). | No | integer |
| page | query | Page number (defaults to 1). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get your deposits history. | [ [Deposit](#deposit) ] |

### /api/v2/peatio/account/balances/{currency}

#### GET
##### Description

Get user account by currency

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | path | The currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get user account by currency | [Account](#account) |

### /api/v2/peatio/account/balances

#### GET
##### Description

Get list of user accounts

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| limit | query | Limit the number of returned paginations. Defaults to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| nonzero | query | Filter non zero balances. | No | Boolean |
| search | query |  | No | json |
| search[currency_code] | query |  | No | string |
| search[currency_name] | query |  | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of user accounts | [ [Account](#account) ] |

### /api/v2/peatio/market/trades

#### GET
##### Description

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

### /api/v2/peatio/market/orders/cancel

#### POST
##### Description

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

### /api/v2/peatio/market/orders/{id}/cancel

#### POST
##### Description

Cancel an order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Cancel an order. |

### /api/v2/peatio/market/orders

#### POST
##### Description

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
##### Description

Get your orders, result is paginated.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query |  | No | string |
| base_unit | query |  | No | string |
| quote_unit | query |  | No | string |
| state | query | Filter order by state. | No | string |
| limit | query | Limit the number of returned orders, default to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| order_by | query | If set, returned orders will be sorted in specific order, default to "desc". | No | string |
| ord_type | query | Filter order by ord_type. | No | string |
| type | query | Filter order by type. | No | string |
| time_from | query | An integer represents the seconds elapsed since Unix epoch.If set, only orders created after the time will be returned. | No | integer |
| time_to | query | An integer represents the seconds elapsed since Unix epoch.If set, only orders created before the time will be returned. | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get your orders, result is paginated. | [ [Order](#order) ] |

### /api/v2/peatio/market/orders/{id}

#### GET
##### Description

Get information of specified order.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path |  | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get information of specified order. | [Order](#order) |

### /api/v2/peatio/coinmarketcap/orderbook/{market_pair}

#### GET
##### Description

Get depth or specified market

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market_pair | path | A pair such as "LTC_BTC" | Yes | string |
| depth | query | Orders depth quantity: [0,5,10,20,50,100,500] | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get depth or specified market |

### /api/v2/peatio/coinmarketcap/trades/{market_pair}

#### GET
##### Description

Get recent trades on market

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market_pair | path | A pair such as "LTC_BTC" | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get recent trades on market | [Trade](#trade) |

### /api/v2/peatio/coinmarketcap/ticker

#### GET
##### Description

Get 24-hour pricing and volume summary for each market pair

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get 24-hour pricing and volume summary for each market pair | [Ticker](#ticker) |

### /api/v2/peatio/coinmarketcap/assets

#### GET
##### Description

Details on crypto currencies available on the exchange

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Details on crypto currencies available on the exchange |

### /api/v2/peatio/coinmarketcap/summary

#### GET
##### Description

Overview of market data for all tickers and all market pairs on the exchange

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Overview of market data for all tickers and all market pairs on the exchange |

### /api/v2/peatio/coingecko/historical_trades

#### GET
##### Description

Get recent trades on market

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| ticker_id | query | A pair such as "LTC_BTC" | Yes | string |
| type | query | To indicate nature of trade - buy/sell | No | string |
| limit | query | Number of historical trades to retrieve from time of query. [0, 200, 500...]. 0 returns full history | No | integer |
| start_time | query |  | No | integer |
| end_time | query |  | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get recent trades on market |

### /api/v2/peatio/coingecko/orderbook

#### GET
##### Description

Get depth or specified market

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| ticker_id | query | A pair such as "LTC_BTC" | Yes | string |
| depth | query | Orders depth quantity: [0, 100, 200, 500...] | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get depth or specified market |

### /api/v2/peatio/coingecko/tickers

#### GET
##### Description

Get list of all available trading pairs

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of all available trading pairs | [Ticker](#ticker) |

### /api/v2/peatio/coingecko/pairs

#### GET
##### Description

Get list of all available trading pairs

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | Get list of all available trading pairs |

### Models

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

#### Ticker

Get list of all available trading pairs

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| at | integer | Timestamp of ticker | No |
| ticker | [TickerEntry](#tickerentry) | Ticker entry for specified time | No |

#### TickerEntry

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| low | double | The lowest trade price during last 24 hours (0.0 if no trades executed during last 24 hours) | No |
| high | double | The highest trade price during last 24 hours (0.0 if no trades executed during last 24 hours) | No |
| open | double | Price of the first trade executed 24 hours ago or less | No |
| last | double | The last executed trade price | No |
| volume | double | Total volume of trades executed during last 24 hours | No |
| amount | double | Total amount of trades executed during last 24 hours | No |
| vol | double | Alias to volume | No |
| avg_price | double | Average price more precisely VWAP is calculated by adding up the total traded for every transaction(price multiplied by the number of shares traded) and then dividing by the total shares traded | No |
| price_change_percent | string | Price change in the next format +3.19%.Price change is calculated using next formula (last - open) / open * 100% | No |
| at | integer | Timestamp of ticker | No |

#### Trade

Get recent trades on market

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Trade ID. | No |
| price | double | Trade price. | No |
| amount | double | Trade amount. | No |
| total | double | Trade total (Amount * Price). | No |
| fee_currency | double | Currency user's fees were charged in. | No |
| fee | double | Percentage of fee user was charged for performed trade. | No |
| fee_amount | double | Amount of fee user was charged for performed trade. | No |
| market | string | Trade market id. | No |
| created_at | string | Trade create time in iso8601 format. | No |
| taker_type | string | Trade taker order type (sell or buy). | No |
| side | string | Trade side. | No |
| order_id | integer | Order id. | No |

#### OrderBook

Get the order book of specified market.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| asks | [ [Order](#order) ] | Asks in orderbook | No |
| bids | [ [Order](#order) ] | Bids in orderbook | No |

#### Order

Get your orders, result is paginated.

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
| trades | [ [Trade](#trade) ] | Trades wiht this order. | No |

#### Market

Get all available markets.

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

#### Currency

Get a currency

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Currency code.<br>_Example:_ `"btc"` | No |
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
| base_factor | string | Currency base factor<br>_Example:_ `100000000` | No |
| precision | string | Currency precision<br>_Example:_ `8` | No |
| position | string | Position used for defining currencies order<br>_Example:_ `8` | No |
| icon_url | string | Currency icon<br>_Example:_ `"https://upload.wikimedia.org/wikipedia/commons/0/05/Ethereum_logo_2014.svg"` | No |
| min_confirmations | string | Number of confirmations required for confirming deposit or withdrawal | No |

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
| transfer_type | string | Withdraw transfer type | No |
| created_at | string | The datetimes for the withdrawal. | No |
| updated_at | string | The datetimes for the withdrawal. | No |
| done_at | string | The datetime when withdraw was completed | No |

#### Beneficiary

Get list of user beneficiaries

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
| transfer_type | string | Deposit transfer type | No |
| created_at | string | The datetime when deposit was created. | No |
| completed_at | string | The datetime when deposit was completed.. | No |
| tid | string | The shared transaction ID | No |

#### Account

Get list of user accounts

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| currency | string | Currency code. | No |
| balance | double | Account balance. | No |
| locked | double | Account locked funds. | No |

#### Transactions

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| address | string | Recipient address of transaction. | No |
| currency | string | Transaction currency id. | No |
| amount | double | Transaction amount. | No |
| fee | double | Transaction fee. | No |
| txid | string | Transaction id. | No |
| state | string | Transaction state. | No |
| note | string | Withdraw note. | No |
| confirmations | integer | Number of confirmations. | No |
| created_at | string | Transaction created time in iso8601 format. | No |
| updated_at | string | Transaction updated time in iso8601 format. | No |
| type | string | Type of transaction | No |

#### Member

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| uid | string | Member UID. | No |
| email | string | Member email. | No |
| accounts | [ [Account](#account) ] | Member accounts. | No |
