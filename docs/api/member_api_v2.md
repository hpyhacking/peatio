Member API v2
=============
Member API is API which can be used by client application like SPA.

**Version:** 1.9.1-rc.12

**Contact information:**  
peatio.tech  
https://www.peatio.tech  
hello@peatio.tech  

**License:** https://github.com/rubykube/peatio/blob/master/LICENSE.md

### Security
---
**Bearer**  

|apiKey|*API Key*|
|---|---|
|Name|JWT|
|In|header|

### /v2/accounts/{currency}
---
##### ***GET***
**Description:** Get user account by currency

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | path | The currency code. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get user account by currency | [Account](#account) |

### /v2/accounts
---
##### ***GET***
**Description:** Get list of user accounts

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of user accounts | [ [Account](#account) ] |

### /v2/markets
---
##### ***GET***
**Description:** Get all available markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get all available markets. |

### /v2/tickers/{market}
---
##### ***GET***
**Description:** Get ticker of specific market.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get ticker of specific market. |

### /v2/tickers
---
##### ***GET***
**Description:** Get ticker of all markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get ticker of all markets. |

### /v2/members/me
---
##### ***GET***
**Description:** Get your profile and accounts info.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get your profile and accounts info. |

### /v2/deposits
---
##### ***GET***
**Description:** Get your deposits history.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Currency value contains bch,btc,dash,eth,ltc,trst,usd,xrp,BCH,BTC,DASH,ETH,LTC,TRST,USD,XRP | No | string |
| limit | query | Set result limit. | No | integer |
| state | query |  | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get your deposits history. |

### /v2/deposit
---
##### ***GET***
**Description:** Get details of specific deposit.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| txid | query |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get details of specific deposit. |

### /v2/deposit_address
---
##### ***POST***
**Description:** Returns new deposit address for account you want to deposit to. The address may be blank because address generation process is still in progress. If this case you should try again later. 

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The account you want to deposit to. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Returns new deposit address for account you want to deposit to. The address may be blank because address generation process is still in progress. If this case you should try again later.  |

##### ***GET***
**Description:** Returns deposit address for account you want to deposit to. The address may be blank because address generation process is still in progress. If this case you should try again later.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | The account you want to deposit to. | Yes | string |
| address_format | query | Address format legacy/cash | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns deposit address for account you want to deposit to. The address may be blank because address generation process is still in progress. If this case you should try again later. |

### /v2/orders/clear
---
##### ***POST***
**Description:** Cancel all my orders.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| side | formData | If present, only sell orders (asks) or buy orders (bids) will be canncelled. | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Cancel all my orders. |

### /v2/orders
---
##### ***POST***
**Description:** Create a Sell/Buy order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | formData | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| side | formData | Either 'sell' or 'buy'. | Yes | string |
| volume | formData | The amount user want to sell/buy. An order could be partially executed, e.g. an order sell 5 btc can be matched with a buy 3 btc order, left 2 btc to be sold; in this case the order's volume would be '5.0', its remaining_volume would be '2.0', its executed volume is '3.0'. | Yes | float |
| ord_type | formData |  | No | string |
| price | formData | Price for each unit. e.g. If you want to sell/buy 1 btc at 3000 usd, the price is '3000.0' | Yes | float |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create a Sell/Buy order. |

##### ***GET***
**Description:** Get your orders, results is paginated.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| state | query | Filter order by state, default to 'wait' (active orders). | No | string |
| limit | query | Limit the number of returned orders, default to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| order_by | query | If set, returned orders will be sorted in specific order, default to 'asc'. | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get your orders, results is paginated. |

### /v2/orders/multi
---
##### ***POST***
**Description:** Create multiple sell/buy orders.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | formData | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| orders[side] | formData | Either 'sell' or 'buy'. | Yes | [ string ] |
| orders[volume] | formData | The amount user want to sell/buy. An order could be partially executed, e.g. an order sell 5 btc can be matched with a buy 3 btc order, left 2 btc to be sold; in this case the order's volume would be '5.0', its remaining_volume would be '2.0', its executed volume is '3.0'. | Yes | [ float ] |
| orders[ord_type] | formData |  | No | [ string ] |
| orders[price] | formData | Price for each unit. e.g. If you want to sell/buy 1 btc at 3000 usd, the price is '3000.0' | Yes | [ float ] |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create multiple sell/buy orders. |

### /v2/order/delete
---
##### ***POST***
**Description:** Cancel an order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique order id. | Yes | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Cancel an order. |

### /v2/order
---
##### ***GET***
**Description:** Get information of specified order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | query | Unique order id. | Yes | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get information of specified order. |

### /v2/order_book
---
##### ***GET***
**Description:** Get the order book of specified market.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| asks_limit | query | Limit the number of returned sell orders. Default to 20. | No | integer |
| bids_limit | query | Limit the number of returned buy orders. Default to 20. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get the order book of specified market. |

### /v2/depth
---
##### ***GET***
**Description:** Get depth or specified market. Both asks and bids are sorted from highest price to lowest.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| limit | query | Limit the number of returned price levels. Default to 300. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get depth or specified market. Both asks and bids are sorted from highest price to lowest. |

### /v2/trades/my
---
##### ***GET***
**Description:** Get your executed trades. Trades are sorted in reverse creation order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| limit | query | Limit the number of returned trades. Default to 50. | No | integer |
| timestamp | query | An integer represents the seconds elapsed since Unix epoch. If set, only trades executed before the time will be returned. | No | integer |
| from | query | Trade id. If set, only trades created after the trade will be returned. | No | integer |
| to | query | Trade id. If set, only trades created before the trade will be returned. | No | integer |
| order_by | query | If set, returned trades will be sorted in specific order, default to 'desc'. | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get your executed trades. Trades are sorted in reverse creation order. |

### /v2/trades
---
##### ***GET***
**Description:** Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| limit | query | Limit the number of returned trades. Default to 50. | No | integer |
| timestamp | query | An integer represents the seconds elapsed since Unix epoch. If set, only trades executed before the time will be returned. | No | integer |
| from | query | Trade id. If set, only trades created after the trade will be returned. | No | integer |
| to | query | Trade id. If set, only trades created before the trade will be returned. | No | integer |
| order_by | query | If set, returned trades will be sorted in specific order, default to 'desc'. | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order. |

### /v2/k
---
##### ***GET***
**Description:** Get OHLC(k line) of specific market.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| period | query | Time period of K line, default to 1. You can choose between 1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080 | No | integer |
| time_from | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned. | No | integer |
| time_to | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data till that time will be returned. | No | integer |
| limit | query | Limit the number of returned data points default to 30. Ignored if time_from and time_to are given. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get OHLC(k line) of specific market. |

### /v2/k_with_pending_trades
---
##### ***GET***
**Description:** Get K data with pending trades, which are the trades not included in K data yet, because there's delay between trade generated and processed by K data generator.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| trade_id | query | The trade id of the first trade you received. | Yes | integer |
| period | query | Time period of K line, default to 1. You can choose between 1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080 | No | integer |
| time_from | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned. | No | integer |
| time_to | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data till that time will be returned. | No | integer |
| limit | query | Limit the number of returned data points, default to 30. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get K data with pending trades, which are the trades not included in K data yet, because there's delay between trade generated and processed by K data generator. |

### /v2/timestamp
---
##### ***GET***
**Description:** Get server current time, in seconds since Unix epoch.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get server current time, in seconds since Unix epoch. |

### /v2/withdraws
---
##### ***GET***
**Description:** List your withdraws as paginated collection.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Any supported currencies: bch,btc,dash,eth,ltc,trst,usd,xrp,BCH,BTC,DASH,ETH,LTC,TRST,USD,XRP. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of withdraws per page (defaults to 100, maximum is 1000). | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | List your withdraws as paginated collection. |

### /v2/sessions
---
##### ***DELETE***
**Description:** Delete all user sessions.

**Responses**

| Code | Description |
| ---- | ----------- |
| 204 | Delete all user sessions. |

##### ***POST***
**Description:** Create new user session.

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create new user session. |

### /v2/fees/trading
---
##### ***GET***
**Description:** Returns trading fees for markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns trading fees for markets. |

### /v2/fees/deposit
---
##### ***GET***
**Description:** Returns deposit fees for currencies.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns deposit fees for currencies. |

### /v2/fees/withdraw
---
##### ***GET***
**Description:** Returns withdraw fees for currencies.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns withdraw fees for currencies. |

### /v2/member_levels
---
##### ***GET***
**Description:** Returns list of member levels and the privileges they provide.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns list of member levels and the privileges they provide. |

### /v2/currency/trades
---
##### ***GET***
**Description:** Get currency trades at last 24h

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get currency trades at last 24h |

### /v2/currencies
---
##### ***GET***
**Description:** Get list of currencies

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| type | query | Currency type | No | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of currencies | [ [Currency](#currency) ] |

### /v2/currencies/{id}
---
##### ***GET***
**Description:** Get a currency

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Currency code. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get a currency | [Currency](#currency) |

### Models
---

### Account  

Get list of user accounts

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| currency | string | Currency code. | No |
| balance | double | Account balance. | No |
| locked | double | Account locked funds. | No |

### Currency  

Get a currency

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Currency code. | No |
| symbol | string | Currency symbol | No |
| explorer_transaction | string | Currency transaction exprorer url template | No |
| explorer_address | string | Currency address exprorer url template | No |
| type | string | Currency type | No |
| deposit_fee | string | Currency deposit fee | No |
| withdraw_fee | string | Currency withdraw fee | No |
| quick_withdraw_limit | string | Currency quick withdraw limit | No |
| base_factor | string | Currency base factor | No |
| precision | string | Currency precision | No |
| icon_url | string | Currency icon | No |