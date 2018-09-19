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
* `<market>.update` (global state updates)
* `<market>.trades` 

List of supported private streams (requires authentication):
* `order`
* `trade` 
* `deposit_address` 

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

#### Order

Here is structure of `Order` object:

| Field           | Description                                |
|-----------------|--------------------------------------------|
| `id`            | Unique order id.                           |
| `side`          | Either `sell` or `buy`.                    |
| `ord_type`      | Type of order, either `limit` or `market`. |
| `price`         | Price for each unit.                       |
| `avg_price`     | Average execution price.                   |
| `state`         | One of `wait`, `done`, or `cancel`.        |
| `market_id`     | The market in which the order is placed.   |
| `created_at`    | Order create time in `iso8601` format.     |
| `origin_volume` | The amount user want to sell/buy.          |
| `trades_count`  | Number of trades.                          |
| `trades`        | List of trades.                            |

#### Trade

Here is structure of `Trade` object:

| Field        | Description                              |
|--------------|----------------------------------------- |
| `id`         | Uniq trade id.                           |
| `price`      | Price for each unit.                     |
| `volume`     | The amount of trade.                     |
| `funds`      |                                          |
| `market_id`  | The market in which the order is placed. |
| `created_at` | Uniq trade id.                           |
| `side`       | Type of order, either `bid` or `ask`.    |
| `order_id`   | Order that placed.                       |
| `bid`        | Bid order object.                        |
| `ask`        | Ask order object.                        |

### Development

Start websocket server using following command in peatio-core git repository:

```bash
$ ./bin/peatio service start ranger
```

In peatio git repository call `./bin/rails c` and get a jwt token:
```ruby
irb(main):001:0> Member.first.authentications.first.token
```

Or you can obtain a JWT token after authentication in Baron.

Now we can test authentication with [wscat](https://github.com/websockets/wscat):

Connect to public usdeth channel:

```bash
$ wscat -n -c 'ws://ws.ranger.wb.local?stream=usdeth'
```

Send a JWT authentication payload:
```
{ "jwt": "Bearer <token>" }
```

### Examples

There is also [example of working with Ranger service using
NodeJS.](https://github.com/rubykube/ranger-example-nodejs)
