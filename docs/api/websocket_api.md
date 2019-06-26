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
* [`<market>.update`](#update) (global state updates)
* [`<market>.trades` ](#trades)
* [`<market>.kline-PERIOD` ](#kline-point) (available periods are "1m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "12h", "1d", "3d", "1w")
* [`global.tickers`](#tickers)

List of supported private streams (requires authentication):
* [`order`](#order)
* [`trade`](#trade) 

You can find a format of these events below in the doc.


## Public channels architecture

![scheme](assets/scheme_ranger_public_channels.png)

## Private channels architecture

![scheme](assets/scheme_ranger_private_channels.png)

### Authentication

Authentication happens on websocket message with following JSON structure.

```JSON
{
  "jwt": "Bearer <Token>"
}
```

If authenticaton was done, server will respond successfully

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

If other error occured during the message handling server throws an error

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


When user successfully authenticated server subsribes client to given streams
passed as GET request parameter `?stream=` (can be specified multiple times)

When order or trade done, websocket server send message to client with object details.

Depending on what trade happend server will send the `ask` and `bid` details.

### Public streams

#### Update

Here is structure of `<market.update>` event:

| Field  | Description                                             |
| ------ | ------------------------------------------------------- |
| `asks` | Added asks with price and total volume expose as array. |
| `bids` | Added bids with price and total volume expose as array. |

Example:

```ruby
{
  asks: [[0.4e1, 0.1e-1], [0.3e1, 0.401e1]], # first is price & second is total volume
  bids: [[0.5e1, 0.4e1]]
}
```

#### Trades

Here is structure of `<market.trades>` event expose as array with trades:

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
| `side`             | Type of order, either `but` or `sell`.                        |
| `ord_type`         | Order tyep, either `limit` or `market`.                      |
| `price`            | Order price.                                                 |
| `avg_price`        | Order average price.                                         |
| `state`            | One of `wait`, `done`, or `cancel`.                          |
| `origin_volume`    | The amount user want to sell/buy.                            |
| `remaining_volume` | Remaining amount user want to sell/buy.                      |
| `executed_volume`  | Executed amount for current order.                           |
| `created_at`       | Order create time.                                           |
| `updated_at`       | Order create time.                                           |
| `trades_count`     | Trades wiht this order.                                      |
| `kind`             | Type of order, either `bid` or `ask`. (Deprecated)           |
| `at`               | Order create time. (Deprecated) (In peatio `created_at`)     |

#### Trade

Here is structure of `Trade` event:

| Field           | Description                                                  |
| --------------- | ------------------------------------------------------------ |
| `id`            | Uniq trade id.                                               |
| `side`          | Type of order in trade that related to current user `bid` or `ask`.   |
| `price`         | Price for each unit.                                         |
| `volume`        | The amount of trade.                                         |
| `market`        | The market in which the trade is placed. (In peatio market_id) |
| `created_at`    | Trade create time. (In peatio created_at)                    |
| `ask_id/bid_id` | Ask or bid id depending on which order has user in trade.    |
| `kind`          | Type of order in trade that related to current user `bid` or `ask`. (Deprecated)   |
| `at`            | Trade create time. (Deprecated) (In peatio `created_at`)     |


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
