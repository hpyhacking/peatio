# Peatio WebSocket API

Peatio WebSocket API connections are handled by Ranger service provided by
[peatio gem](https://github.com/rubykube/peatio-core).

### API

There are two types of channels:
 * Public: accessible by anyone
 * Private: accessible only by given member

GET request parameters:

| Field    | Description                         | Multiple allowed |
|----------|-------------------------------------|------------------|
| `stream` | List of streams to be subscribed on | Yes              |

List of supported public streams:
* [`<market>.ob-inc`](#order-book) market order-book update
* [`<market>.trades` ](#trades)
* [`<market>.kline-PERIOD` ](#kline-point) (available periods are "1m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "12h", "1d", "3d", "1w")
* [`global.tickers`](#tickers)

List of supported private streams (requires authentication):
* [`order`](#order)
* [`trade`](#trade)

You can find a format of these events below in the doc.

### Authentication

Authentication happens on websocket message with following JSON structure.

```JSON
{
  "jwt": "Bearer <Token>"
}
```

If authentication was done, server will respond successfully

```JSON
{
  "success": {
    "message": "Authenticated."
  }
}
```

Otherwise server will return an error

```JSON
{
  "error": {
    "message": "Authentication failed."
  }
}
```

If authentication JWT token has invalid type, server return an error

```JSON
{
  "error": {
    "message": "Token type is not provided or invalid."
  }
}
```

If other error occurred during the message handling server throws an error

```JSON
{
  "error": {
    "message": "Error while handling message."
  }
}
```

**Note:** Peatio websocket API supports authentication only Bearer type of JWT token.

**Example** of authentication message:

```JSON
{
  "jwt": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
}
```

### Streams subscription

#### Using  parameters

You can specify streams to subscribe to by passing the `stream` GET parameter in the connection URL. The parameter can be specified multiple times for subscribing to multiple streams.

example:

```
wss://demo.openware.com/api/v2/ranger/public/?stream=global.tickers&stream=ethusd.trades
```

This will subscribe you to *tickers* and *trades* events from *ethusd* market once the connection is established.

#### Subscribe and unsubscribe events
You can manage the connection subscriptions by send the following events after the connection is established:

Subscribe event will subscribe you to the list of  streams provided:

```json
{"event":"subscribe","streams":["ethusd.trades","ethusd.ob-inc"]}
```

The server confirms the subscription with the following message and provides the new list of your current subscrictions:

```json
{"success":{"message":"subscribed","streams":["global.tickers","ethusd.trades","ethusd.ob-inc"]}}
```

Unsubscribe event will unsubscribe you to the list of  streams provided:

```json
{"event":"unsubscribe","streams":["ethusd.trades","ethusd.ob-inc"]}
```

The server confirms the unsubscription with the following message and provides the new list of your current subscrictions:

```json
{"success":{"message":"unsubscribed","streams":["global.tickers","ethusd.kline-15m"]}}
```


### Public streams

#### Order-Book

This stream sends a snapshot of the order-book at the subscription time, then it sends increments. Volumes information in increments replace the previous values. If the volume is zero the price point should be removed from the order-book.

Register to stream `<market>.ob-inc` to receive snapshot and increments messages.

Example of order-book snapshot:

```json
{
    "eurusd.ob-snap":{
        "asks":[
            ["15.0","21.7068"],
            ["20.0","100.2068"],
            ["20.5","30.2068"],
            ["30.0","21.2068"]
        ],
        "bids":[
            ["10.95","21.7068"],
            ["10.90","65.2068"],
            ["10.85","55.2068"],
            ["10.70","30.2068"]
        ]
    }
}
```



Example of order-book increment message:

```json
 {
     "eurusd.ob-inc":{
         "asks":[
             ["15.0","22.1257"]
         ]
     }
 }
```



#### Trades

Here is structure of `<market>.trades` event expose as array with trades:

| Field          | Description                                  |
| -------------- | -------------------------------------------- |
| `tid`          | Unique trade tid.                            |
| `taker_type`   | Taker type of trade, either `buy` or `sell`. |
| `price`        | Price for the trade.                         |
| `amount`       | The amount of trade.                         |
| `created_at`   | Trade create time.                           |

#### Kline point

Kline point as array of numbers:

1. Timestamp.
2. Open price.
3. Max price.
4. Min price.
5. Last price.
6. Period volume

Example:

```ruby
[1537370580, 0.0839, 0.0921, 0.0781, 0.0845, 0.5895]
```


#### Tickers

Here is structure of `global.tickers` event expose as array with all markets pairs:

| Field                  | Description                     |
| -----------------------| ------------------------------- |
| `at`                   | Date of current ticker.         |
| `name`                 | Market pair name.               |
| `base_unit`            | Base currency.                  |
| `quote_unit`           | Quote currency.                 |
| `low`                  | Lowest price in 24 hours.       |
| `high`                 | Highest price in 24 hours.      |
| `last`                 | Last trade price.               |
| `open`                 | Last trade from last timestamp. |
| `close`                | Last trade price.               |
| `volume`               | Volume in 24 hours.             |
| `sell`                 | Best price per unit.            |
| `buy`                  | Best price per unit.            |
| `avg_price`            | Average price for last 24 hours.|
| `price_change_percent` | Average price change in percent.|

### Private streams

#### Order

Here is structure of `Order` event:

| Field              | Description                                                  |
| ------------------ | ------------------------------------------------------------ |
| `id`               | Unique order id.                                             |
| `market`           | The market in which the order is placed. (In peatio `market_id`) |
| `order_type`       | Order type, either `limit` or `market`.                      |
| `price`            | Order price.                                                 |
| `avg_price`        | Order average price.                                         |
| `state`            | One of `wait`, `done`, `reject` or `cancel`.                 |
| `origin_volume`    | The amount user want to sell/buy.                            |
| `remaining_volume` | Remaining amount user want to sell/buy.                      |
| `executed_volume`  | Executed amount for current order.                           |
| `created_at`       | Order create time.                                           |
| `updated_at`       | Order create time.                                           |
| `trades_count`     | Trades with this order.                                      |
| `kind`             | Type of order, either `bid` or `ask`. (Deprecated)           |
| `at`               | Order create time. (Deprecated) (In peatio `created_at`)     |

#### Trade

Here is structure of `Trade` event:

| Field        | Description                                                  |
| ------------ | ------------------------------------------------------------ |
| `id`         | Unique trade identifier.                                     |
| `price`      | Price for each unit.                                         |
| `amount`     | The amount of trade.                                         |
| `total`      | The total of trade (volume * price).                         |
| `market`     | The market in which the trade is placed. (In peatio market_id) |
| `side`       | Type of order in trade that related to current user `sell` or `buy`. |
| `taker_type` | Order side of the taker for the trade, either `buy` or `sell`. |
| `created_at` | Trade create time.                                           |
| `order_id`   | User order identifier in trade.                              |


### Development

Start ranger websocket server using following command in peatio-core gem:

```bash
$ ./bin/peatio service start ranger
```

Now we can test authentication with [wscat](https://github.com/websockets/wscat):

#### Connect to public channel:

```bash
$ wscat -n -c 'ws://ws.app.local:8080/api/ranger/v2?stream=usdeth'
```

#### Connect to private channel:

Authorization header will be injected automatically by ambassador so we could subscribe to private channels.
```bash
$ wscat -n -c 'ws://ws.app.local:8080/api/ranger/v2?stream=trade'
```

### Examples

There is also [example of working with Ranger service using NodeJS.](https://github.com/rubykube/ranger-example-nodejs)
