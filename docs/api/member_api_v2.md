Member API v2
=============
Member API is API which can be used by client application like SPA.

**Version:** 1.8.16

**License:** https://github.com/rubykube/peatio/blob/master/LICENSE.md

### /v2/markets
---
##### ***GET***
**Summary:** Get all available markets.

**Description:** Get all available markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get all available markets. |

### /v2/tickers/{market}
---
##### ***GET***
**Summary:** Get ticker of specific market.

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
**Summary:** Get ticker of all markets.

**Description:** Get ticker of all markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get ticker of all markets. |

### /v2/members/me
---
##### ***GET***
**Summary:** Get your profile and accounts info.

**Description:** Get your profile and accounts info.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get your profile and accounts info. |

### /v2/deposits
---
##### ***GET***
**Summary:** Get your deposits history.

**Description:** Get your deposits history.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Currency value contains usd,btc,xrp,bch,ltc,dash,eth,trst,USD,BTC,XRP,BCH,LTC,DASH,ETH,TRST | No | string |
| limit | query | Set result limit. | No | integer |
| state | query |  | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get your deposits history. |

### /v2/deposit
---
##### ***GET***
**Summary:** Get details of specific deposit.

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
##### ***GET***
**Summary:** Where to deposit. The address field could be empty when a new address is generating (e.g. for bitcoin), you should try again later in that case.

**Description:** Where to deposit. The address field could be empty when a new address is generating (e.g. for bitcoin), you should try again later in that case.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | The account to which you want to deposit. Available values: btc, xrp, bch, ltc, dash, eth, trst, BTC, XRP, BCH, LTC, DASH, ETH, TRST | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Where to deposit. The address field could be empty when a new address is generating (e.g. for bitcoin), you should try again later in that case. |

### /v2/orders/clear
---
##### ***POST***
**Summary:** Cancel all my orders.

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
**Summary:** Create a Sell/Buy order.

**Description:** Create a Sell/Buy order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | formData | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| side | formData | Either 'sell' or 'buy'. | Yes | string |
| volume | formData | The amount user want to sell/buy. An order could be partially executed, e.g. an order sell 5 btc can be matched with a buy 3 btc order, left 2 btc to be sold; in this case the order's volume would be '5.0', its remaining_volume would be '2.0', its executed volume is '3.0'. | Yes | string |
| price | formData | Price for each unit. e.g. If you want to sell/buy 1 btc at 3000 usd, the price is '3000.0' | Yes | string |
| ord_type | formData |  | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create a Sell/Buy order. |

##### ***GET***
**Summary:** Get your orders, results is paginated.

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
**Summary:** Create multiple sell/buy orders.

**Description:** Create multiple sell/buy orders.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | formData | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| orders[side] | formData | Either 'sell' or 'buy'. | Yes | [ string ] |
| orders[volume] | formData | The amount user want to sell/buy. An order could be partially executed, e.g. an order sell 5 btc can be matched with a buy 3 btc order, left 2 btc to be sold; in this case the order's volume would be '5.0', its remaining_volume would be '2.0', its executed volume is '3.0'. | Yes | [ string ] |
| orders[price] | formData | Price for each unit. e.g. If you want to sell/buy 1 btc at 3000 usd, the price is '3000.0' | Yes | [ string ] |
| orders[ord_type] | formData |  | No | [ string ] |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create multiple sell/buy orders. |

### /v2/order/delete
---
##### ***POST***
**Summary:** Cancel an order.

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
**Summary:** Get information of specified order.

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
**Summary:** Get the order book of specified market.

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
**Summary:** Get depth or specified market. Both asks and bids are sorted from highest price to lowest.

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
**Summary:** Get your executed trades. Trades are sorted in reverse creation order.

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
**Summary:** Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.

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
**Summary:** Get OHLC(k line) of specific market.

**Description:** Get OHLC(k line) of specific market.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| limit | query | Limit the number of returned data points, default to 30. | No | integer |
| period | query | Time period of K line, default to 1. You can choose between 1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080 | No | integer |
| timestamp | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get OHLC(k line) of specific market. |

### /v2/k_with_pending_trades
---
##### ***GET***
**Summary:** Get K data with pending trades, which are the trades not included in K data yet, because there's delay between trade generated and processed by K data generator.

**Description:** Get K data with pending trades, which are the trades not included in K data yet, because there's delay between trade generated and processed by K data generator.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | query | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| trade_id | query | The trade id of the first trade you received. | Yes | integer |
| limit | query | Limit the number of returned data points, default to 30. | No | integer |
| period | query | Time period of K line, default to 1. You can choose between 1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080 | No | integer |
| timestamp | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get K data with pending trades, which are the trades not included in K data yet, because there's delay between trade generated and processed by K data generator. |

### /v2/timestamp
---
##### ***GET***
**Summary:** Get server current time, in seconds since Unix epoch.

**Description:** Get server current time, in seconds since Unix epoch.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get server current time, in seconds since Unix epoch. |

### /v2/withdraws
---
##### ***POST***
**Summary:** [DEPRECATED] Create withdraw.

**Description:** [DEPRECATED] Create withdraw.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | Any supported currency: usd,btc,xrp,bch,ltc,dash,eth,trst,USD,BTC,XRP,BCH,LTC,DASH,ETH,TRST. | Yes | string |
| amount | formData | Withdraw amount without fees. | Yes | double |
| rid | formData | The shared recipient ID. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | [DEPRECATED] Create withdraw. |

##### ***GET***
**Summary:** List your withdraws as paginated collection.

**Description:** List your withdraws as paginated collection.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | Any supported currencies: usd,btc,xrp,bch,ltc,dash,eth,trst,USD,BTC,XRP,BCH,LTC,DASH,ETH,TRST. | No | string |
| page | query | Page number (defaults to 1). | No | integer |
| limit | query | Number of withdraws per page (defaults to 100, maximum is 1000). | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | List your withdraws as paginated collection. |

### /v2/sessions
---
##### ***DELETE***
**Summary:** Delete all user sessions.

**Description:** Delete all user sessions.

**Responses**

| Code | Description |
| ---- | ----------- |
| 204 | Delete all user sessions. |

##### ***POST***
**Summary:** Create new user session.

**Description:** Create new user session.

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create new user session. |

### /v2/solvency/liability_proofs/partial_tree/mine
---
##### ***GET***
**Summary:** Returns newest partial tree record for member account of specified currency.

**Description:** Returns newest partial tree record for member account of specified currency.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | The code of any currency with type 'coin'. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns newest partial tree record for member account of specified currency. |

### /v2/solvency/liability_proofs/latest
---
##### ***GET***
**Summary:** Returns newest liability proof record for given currency.

**Description:** Returns newest liability proof record for given currency.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | query | The code of any currency with type 'coin'. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns newest liability proof record for given currency. |

### /v2/fees/trading
---
##### ***GET***
**Summary:** Returns trading fees for markets.

**Description:** Returns trading fees for markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns trading fees for markets. |

### /v2/fees/deposit
---
##### ***GET***
**Summary:** Returns deposit fees for currencies.

**Description:** Returns deposit fees for currencies.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns deposit fees for currencies. |

### /v2/fees/withdraw
---
##### ***GET***
**Summary:** Returns withdraw fees for currencies.

**Description:** Returns withdraw fees for currencies.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns withdraw fees for currencies. |

### /v2/pusher/auth
---
##### ***POST***
**Summary:** Returns the credentials used to subscribe to private Pusher channel. IMPORTANT: Pusher events are not part of Peatio public interface. The events may be changed or removed in further releases. Use this on your own risk.

**Description:** Returns the credentials used to subscribe to private Pusher channel. IMPORTANT: Pusher events are not part of Peatio public interface. The events may be changed or removed in further releases. Use this on your own risk.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| channel_name | formData | The name of the channel being subscribed to. Example: private-SN362ECB6F7D. | Yes | string |
| socket_id | formData | An unique identifier for the connected client. | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Returns the credentials used to subscribe to private Pusher channel. IMPORTANT: Pusher events are not part of Peatio public interface. The events may be changed or removed in further releases. Use this on your own risk. |
