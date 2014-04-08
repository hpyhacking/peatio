# Peatio API v1.0

#### Deeps

* GET /api/deeps/btccny

Return JSON data format:

```
{
  asks: [
    price: String
    amount: String
  ],
  bids: [
    price: String
    amount: String
  ],
  at: Number(time as integer of seconds)
}
```

**Example**

```
$curl https://cn.peatio.com/api/deeps/btccny

{
  "asks": [
    [
      "520001.0",
      "0.0005"
    ],
    ...
    ...
    ...
    [
      "4520.0",
      "0.0799999"
    ]
  ],
  "bids": [
    [
      "3960.0",
      "0.22"
    ],
    ...
    ...
    ...
    [
      "3938.0",
      "0.582568"
    ]
  ],
  "at": 1394006788
}
```

#### Trades

* GET /api/trades
* GET /api/trades?since=tid

Return JSON Data format:
```
{
  date: Number(time as integer of seconds)
  price: String
  amount: String
  tid: Number
  type: String
}
```

**Example**


```
$ curl https://cn.peatio.com/api/trades/btccny

[
  {
    "date": 1391928809,
    "price": "4510.0",
    "amount": "0.01",
    "tid": 4307,
    "type": "sell"
  },
  ...
  ...
  ...
  {
    "date": 1393905441,
    "price": "3938.0",
    "amount": "0.088032",
    "tid": 4495,
    "type": "sell"
  }
]
```

#### Tickers

* GET /api/tickers

Return JSON data format:

```
ticker: {
  buy: String
  sell: String
  low: String
  height: String
  last: String
  val: String
},
at: Number(time as integer of seconds)
```

**Example**

```
$ curl https://cn.peatio.com/api/tickers/btccny

{
  "ticker": {
    "buy": "3960.0",
    "sell": "4520.0",
    "low": "0.0",
    "high": "0.0",
    "last": "3938.0",
    "vol": "0.0"
  },
  "at": 1394007720
}
```
