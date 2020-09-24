# CoinMarketCap API integration

Peatio has a simple way to integrate with CoinMarketCap<br/>
This doc includes technical documentation needed to formulate/standardize exchange API endpoints.<br/>
Exchanges are expected to minimally support the mandatory endpoints outlined below along with their corresponding mandatory data-points for integration.<br/>

## List of supported API endpoints described here:
1. `api/v2/coinmarketcap/summary` - *Overview of market data for all tickers and all markets*<br/>
**Response example:**
```json
[
  {
    "trading_pairs": "Identifier of a ticker with delimiter to separate base/quote",
    "base_currency": "Symbol/currency code of base currency",
    "quote_currency": "Symbol/currency code of base currency",
    "last_price": "Last transacted price of base currency based on given quote currency",
    "lowest_ask": "Lowest Ask price of base currency based on given quote currency",
    "highest_bid": "Highest bid price of base currency based on given quote currency",
    "base_volume": "24-hr volume of market pair denoted in BASE currency",
    "quote_volume": "24-hr volume of market pair denoted in QUOTE currency",
    "price_change_percent_24h":  "24-hr % price change of market pair",
    "highest_price_24h": "Highest price of base currency based on given quote currency in the last 24-hrs",
    "lowest_price_24h": "Lowest price of base currency based on given quote currency in the last 24-hrs"
  }
]
```

2. `api/v2/coinmarketcap/assets` - *The assets endpoint is to provide a detailed summary for each available currency*<br/>
**Response example:**
```json
[
  {
    "CURRENCY_CODE": {
      "name": "Full name of cryptocurrency",
      "unified_cryptoasset_id": "Unique ID of cryptocurrency assigned by Unified Cryptoasset ID",
      "can_withdraw": "Identifies whether withdrawals are  enabled or disabled",
      "can_deposit": "Identifies whether deposits are   enabled or disabled",
      "min_withdraw": "Identifies the single minimum  withdrawal amount of a cryptocurrency"
    }
  }
]
```

3. `/api/v2/coinmarketcap/ticker` - *The ticker endpoint is to provide a 24-hour pricing and volume summary for each available market pair available* <br/>
**Response example:**
```json
[
  {
    "MARKET_NAME": {
      "base_id": "The quote pair Unified Cryptoasset ID",
      "quote_id": "The base pair Unified Cryptoasset ID",
      "last_price": "Last transacted price of base currency   based on given quote currency",
      "base_volume": "24-hour trading volume denoted in BASE  currency",
      "quote_volume": "24 hour trading volume denoted in  QUOTE currency",
      "isFrozen": "Indicates if the market is currently enabled (0) or disabled (1)"
    }
  }
]
```

4. `/api/v2/coinmarketcap/orderbook/:market_pair` - *The order book endpoint is to provide a complete level 2 order book (arranged by best asks/bids) with full depth returned for a given market pair* <br/>
**Parameters:**<br/>
market_pair - A pair such as “LTC_BTC”\
depth - Orders depth quantity: [0,5,10,20,50,100,500].Not defined or 0 = full order book. Depth = 100 means 50 for each bid/ask side.<br/>
**Response example:**
```javascript
[
  {
   "timestamp": "Unix timestamp in milliseconds for when the last updated time occurred‬",
    // An array containing 2 elements. The offer price and quantity for each bid order
   "bids":[
      [
         "12462000",
         "0.04548320"
      ],
      [
         "12457000",
         "3.00000000"
      ]
   ],
   // An array containing 2 elements. The ask price and quantity for each ask order
   "asks":[
      [
         "12506000",
         "2.73042000"
      ],
      [
         "12508000",
         "0.33660000"
      ]
   ]
  }
]
```

5. `/api/v2/coinmarketcap/trades/:market_pair` - *The trades endpoint is to return data on all recently completed trades for a given market pair* <br/>
**Parameters:**<br/>
market_pair - A pair such as “LTC_BTC”<br/>
**Response example:**
```json
[
  {
    "trade_id": "A unique ID associated with the trade for the currency pair transaction",
    "price": "Last transacted price of base currency based on given quote currency",
    "base_volume": "Transaction amount in BASE currency",
    "quote_volume": "Transaction amount in QUOTE currency",
    "timestamp": "Unix timestamp in milliseconds for when the transaction occurred",
    "type": "Used to determine whether or not the transaction originated as a buy or sell"
  }
]
```
