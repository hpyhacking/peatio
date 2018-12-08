Member API v2
=============
Member API is API which can be used by client application like SPA.

**Version:** 2.0.0-alpha

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

### /public/timestamp
---
##### ***GET***
**Description:** Get server current time, in seconds since Unix epoch.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get server current time, in seconds since Unix epoch. |

### /public/member-levels
---
##### ***GET***
**Description:** Returns list of member levels and the privileges they provide.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns list of member levels and the privileges they provide. |

### /public/markets/{market}/tickers
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

### /public/markets/tickers
---
##### ***GET***
**Description:** Get ticker of all markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get ticker of all markets. |

### /public/markets/{market}/k-line
---
##### ***GET***
**Description:** Get OHLC(k line) of specific market.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| period | query | Time period of K line, default to 1. You can choose between 1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080 | No | integer |
| time_from | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned. | No | integer |
| time_to | query | An integer represents the seconds elapsed since Unix epoch. If set, only k-line data till that time will be returned. | No | integer |
| limit | query | Limit the number of returned data points default to 30. Ignored if time_from and time_to are given. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get OHLC(k line) of specific market. |

### /public/markets/{market}/depth
---
##### ***GET***
**Description:** Get depth or specified market. Both asks and bids are sorted from highest price to lowest.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| limit | query | Limit the number of returned price levels. Default to 300. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get depth or specified market. Both asks and bids are sorted from highest price to lowest. |

### /public/markets/{market}/trades
---
##### ***GET***
**Description:** Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| limit | query | Limit the number of returned trades. Default to 50. | No | integer |
| timestamp | query | An integer represents the seconds elapsed since Unix epoch. If set, only trades executed before the time will be returned. | No | integer |
| from | query | Trade id. If set, only trades created after the trade will be returned. | No | integer |
| to | query | Trade id. If set, only trades created before the trade will be returned. | No | integer |
| order_by | query | If set, returned trades will be sorted in specific order, default to 'desc'. | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order. |

### /public/markets/{market}/order-book
---
##### ***GET***
**Description:** Get the order book of specified market.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| market | path | Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcusd'. All available markets can be found at /api/v2/markets. | Yes | string |
| asks_limit | query | Limit the number of returned sell orders. Default to 20. | No | integer |
| bids_limit | query | Limit the number of returned buy orders. Default to 20. | No | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get the order book of specified market. |

### /public/markets
---
##### ***GET***
**Description:** Get all available markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get all available markets. |

### /public/currencies
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

### /public/currencies/{id}
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

### /public/fees/trading
---
##### ***GET***
**Description:** Returns trading fees for markets.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns trading fees for markets. |

### /public/fees/deposit
---
##### ***GET***
**Description:** Returns deposit fees for currencies.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns deposit fees for currencies. |

### /public/fees/withdraw
---
##### ***GET***
**Description:** Returns withdraw fees for currencies.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns withdraw fees for currencies. |

### /account/balances/{currency}
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

### /account/balances
---
##### ***GET***
**Description:** Get list of user accounts

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Get list of user accounts | [ [Account](#account) ] |

### /account/deposit_address/{currency}
---
##### ***GET***
**Description:** Returns deposit address for account you want to deposit to by currency. The address may be blank because address generation process is still in progress. If this case you should try again later.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | path | The account you want to deposit to. | Yes | string |
| address_format | query | Address format legacy/cash | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Returns deposit address for account you want to deposit to by currency. The address may be blank because address generation process is still in progress. If this case you should try again later. |

### /account/deposits/{txid}
---
##### ***GET***
**Description:** Get details of specific deposit.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| txid | path |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get details of specific deposit. |

### /account/deposits
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

### /account/withdraws
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

### /market/trades
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

### /market/orders/cancel
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

### /market/orders/{id}/cancel
---
##### ***POST***
**Description:** Cancel an order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique order id. | Yes | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Cancel an order. |

### /market/orders
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
| state | query | Filter order by state, default to "wait" (active orders). | No | string |
| limit | query | Limit the number of returned orders, default to 100. | No | integer |
| page | query | Specify the page of paginated results. | No | integer |
| order_by | query | If set, returned orders will be sorted in specific order, default to "asc". | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get your orders, results is paginated. |

### /market/orders/{id}
---
##### ***GET***
**Description:** Get information of specified order.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique order id. | Yes | integer |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Get information of specified order. |

### /management/timestamp
---
##### ***POST***
**Description:** Returns server time in seconds since Unix epoch.

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Returns server time in seconds since Unix epoch. |

### /management/withdraws/action
---
##### ***PUT***
**Summary:** Performs action on withdraw.

**Description:** «process» – system will lock the money, check for suspected activity, validate recipient address, and initiate the processing of the withdraw. «cancel»  – system will mark withdraw as «canceled», and unlock the money.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The shared transaction ID. | Yes | string |
| action | formData | The action to perform. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Performs action on withdraw. | [Withdraw](#withdraw) |

### /management/withdraws/new
---
##### ***POST***
**Summary:** Creates new withdraw.

**Description:** Creates new withdraw. The behaviours for fiat and crypto withdraws are different. Fiat: money are immediately locked, withdraw state is set to «submitted», system workers will validate withdraw later against suspected activity, and assign state to «rejected» or «accepted». The processing will not begin automatically. The processing may be initiated manually from admin panel or by PUT /management_api/v1/withdraws/action. Coin: money are immediately locked, withdraw state is set to «submitted», system workers will validate withdraw later against suspected activity, validate withdraw address and 

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| tid | formData | The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied. | No | string |
| rid | formData | The beneficiary ID or wallet address on the Blockchain. | Yes | string |
| currency | formData | The currency code. | Yes | string |
| amount | formData | The amount to withdraw. | Yes | double |
| action | formData | The action to perform. | No | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new withdraw. | [Withdraw](#withdraw) |

### /management/withdraws/get
---
##### ***POST***
**Description:** Returns withdraw by ID.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The shared transaction ID. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns withdraw by ID. | [Withdraw](#withdraw) |

### /management/withdraws
---
##### ***POST***
**Description:** Returns withdraws as paginated collection.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | No | string |
| currency | formData | The currency code. | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of objects per page (defaults to 100, maximum is 1000). | No | integer |
| state | formData | The state to filter by. | No | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns withdraws as paginated collection. | [Withdraw](#withdraw) |

### /management/deposits/state
---
##### ***PUT***
**Description:** Allows to load money or cancel deposit.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The shared transaction ID. | Yes | string |
| state | formData | The new state to apply. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Allows to load money or cancel deposit. | [Deposit](#deposit) |

### /management/deposits/new
---
##### ***POST***
**Description:** Creates new fiat deposit with state set to «submitted». Optionally pass field «state» set to «accepted» if want to load money instantly. You can also use PUT /fiat_deposits/:id later to load money or cancel deposit.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| tid | formData | The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied. | No | string |
| currency | formData | The currency code. | Yes | string |
| amount | formData | The deposit amount. | Yes | double |
| state | formData | The state of deposit. | No | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new fiat deposit with state set to «submitted». Optionally pass field «state» set to «accepted» if want to load money instantly. You can also use PUT /fiat_deposits/:id later to load money or cancel deposit. | [Deposit](#deposit) |

### /management/deposits/get
---
##### ***POST***
**Description:** Returns deposit by TID.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The transaction ID. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns deposit by TID. | [Deposit](#deposit) |

### /management/deposits
---
##### ***POST***
**Description:** Returns deposits as paginated collection.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | No | string |
| currency | formData | The currency code. | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of deposits per page (defaults to 100, maximum is 1000). | No | integer |
| state | formData | The state to filter by. | No | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns deposits as paginated collection. | [Deposit](#deposit) |

### /management/accounts/balance
---
##### ***POST***
**Description:** Queries the account balance for the given UID and currency.

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| currency | formData | The currency code. | Yes | string |

**Responses**

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Queries the account balance for the given UID and currency. | [Balance](#balance) |

### Models
---

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
| withdraw_limit_24h | string | Currency 24h withdraw limit | No |
| withdraw_limit_72h | string | Currency 72h withdraw limit | No |
| base_factor | string | Currency base factor | No |
| precision | string | Currency precision | No |
| icon_url | string | Currency icon | No |

### Account  

Get list of user accounts

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| currency | string | Currency code. | No |
| balance | double | Account balance. | No |
| locked | double | Account locked funds. | No |

### Withdraw  

Returns withdraws as paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| tid | integer | The shared transaction ID. | No |
| uid | string | The shared user ID. | No |
| currency | string | The currency code. | No |
| type | string | The withdraw type (fiat or coin). | No |
| amount | string | The withdraw amount excluding fee. | No |
| fee | string | The exchange fee. | No |
| rid | string | The beneficiary ID or wallet address on the Blockchain. | No |
| state | string | The withdraw state. «prepared» – initial state, money are not locked. «submitted» – withdraw has been allowed by outer service for further validation, money are locked. «canceled» – withdraw has been canceled by outer service, money are unlocked. «accepted» – system has validated withdraw and queued it for processing by worker, money are locked. «rejected» – system has validated withdraw and found errors, money are unlocked. «suspected» – system detected suspicious activity, money are unlocked. «processing» – worker is processing withdraw as the current moment, money are locked. «succeed» – worker has successfully processed withdraw, money are subtracted from the account. «failed» – worker has encountered an unhandled error while processing withdraw, money are unlocked. | No |
| created_at | string | The datetime when withdraw was created. | No |
| blockchain_txid | string | The transaction ID on the Blockchain (coin only). | No |

### Deposit  

Returns deposits as paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| tid | integer | The shared transaction ID. | No |
| currency | string | The currency code. | No |
| uid | string | The shared user ID. | No |
| type | string | The deposit type (fiat or coin). | No |
| amount | string | The deposit amount. | No |
| state | string | The deposit state. «submitted» – initial state. «canceled» – deposit has been canceled by outer service. «rejected» – deposit has been rejected by outer service.. «accepted» – deposit has been accepted by outer service, money are loaded. | No |
| created_at | string | The datetime when deposit was created. | No |
| completed_at | string | The datetime when deposit was completed. | No |
| blockchain_txid | string | The transaction ID on the Blockchain (coin only). | No |
| blockchain_confirmations | string | The number of transaction confirmations on the Blockchain (coin only). | No |

### Balance  

Queries the account balance for the given UID and currency.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| uid | string | The shared user ID. | No |
| balance | string | The account balance. | No |
| locked | string | The locked account balance. | No |