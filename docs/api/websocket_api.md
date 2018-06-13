# Peatio WebSocket API

## API Documentation

On websocket connection client get `challenge`.

At first websocket client have to authenticate.

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

### After authentication

When user successfully authenticated servers subsribes client to orders and trades of authenticated user.

When order or trade done, websocket server send message to client with object details.

Depending on what trade happend server will send the `ask` and `bid` details.

List of subscription channels:

- Order objects send to `orderbook` AMQP channel.
- Trade objects send to `trade` AMQP channel.

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

## Start websocket API

You can start websocket API locally using peatio git repository.

You should have `redis` and `rabbitmq` servers up and running
By default peatio websocket API running on the host `0.0.0.0` and port `8080`

Change host and port by setting environment variables

```yaml
WEBSOCKET_HOST: 0.0.0.0
WEBSOCKET_PORT: 8080
```

### Development

Start websocket server using following command:

```sh
$ bundle exec ruby lib/daemons/websocket_api.rb
```

### Client code sample

Here is base example of **Websocket Client**

- JWT authentication.
- Listeting server messages.

```ruby
# frozen_string_literal: true

require 'rubygems'
require 'websocket-client-simple'
require 'active_support/all'
require 'jwt'

# Create valid JWT
def jwt(email, uid, level, state)
  key     = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV.fetch('JWT_PRIVATE_KEY')))
  payload = {
    iat:   Time.now.to_i,
    exp:   10.minutes.from_now.to_i,
    jti:   SecureRandom.uuid,
    sub:   'session',
    iss:   'barong',
    aud:   ['peatio'],
    email: email,
    uid:   uid,
    level: level,
    state: state
  }
  JWT.encode(payload, key, ENV.fetch('JWT_ALGORITHM'))
end

# Host and port of the websocket server.
host = ENV.fetch('WS_HOST', 'localhost')
port = ENV.fetch('WS_PORT', '8080')
payload = {
  x: 'x', y: 'y', z: 'z',
  email: 'test@gmail.com'
}

# Create websocket connection.
ws = WebSocket::Client::Simple.connect("ws://#{host}:#{port}")

# Called on messaged from websocket server.
ws.on(:message) do |msg|
  puts msg.data
end

# Called if connection to server has been opened.
ws.on(:open) do
  # Authenticate.
  auth = jwt('test@gmail.com', 'test@gmail.com', 3, 'active')
  msg = "{ \"jwt\": \"Bearer #{auth}\"}"

  ws.send msg
end

# Called if connection to server has been closed.
ws.on(:close) do |err|
  p err
  exit 1
end

# Called if any server error occured.
ws.on(:error) do |err|
  p err
end

loop {}
```
