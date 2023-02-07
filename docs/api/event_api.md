# RabbitMQ Peatio Event API

## Overview of RabbitMQ details

Peatio submits all events into three exchanges depending on event category (read next).

The exchange name consists of three parts:

  1) application name, like `peatio`, `barong`.

  2) fixed keyword `events`.

  3) category of event, like `system` (generic system event), `model` (the attributes of some record were updated), `market` (trading events).

The routing key looks like `deposit.updated`, `btcusd.new_order`.
The event name matches the routing key but with event category appended at the beginning, like `model.deposit.updated`, `market.btcusd.new_order`.

## Overview of RabbitMQ message

Each produced message in `Event API` is JWT (complete format).

This is very similar to `Management API`.

The example below demonstrates both generation and verification of JWT:

```ruby
require "jwt-multisig"
require "securerandom"

jwt_payload = {
  iss:   "peatio",
  jti:   SecureRandom.uuid,
  iat:   Time.now.to_i,
  exp:   Time.now.to_i + 60,
  event: {}
}

require "openssl"
private_key = OpenSSL::PKey::RSA.generate(2048)
public_key  = private_key.public_key

generated_jwt = JWT::Multisig.generate_jwt(jwt_payload, { peatio: private_key }, { peatio: "RS256" })

Kernel.puts "GENERATED JWT", generated_jwt.to_json, "\n"

verification_result = JWT::Multisig.verify_jwt generated_jwt.deep_stringify_keys, \
  { peatio: public_key }, { verify_iss: true, iss: "peatio", verify_jti: true }

decoded_jwt_payload = verification_result[:payload]

Kernel.puts "MATCH AFTER VERIFICATION: #{jwt_payload == decoded_jwt_payload}."
```

The RabbitMQ message is stored in JWT field called `event`.

## Overview of Event API message

The typical event looks like (JSON):

```ruby
event: {
  name: "model.deposit.updated",
  foo:  "...",
  bar:  "...",
  qux:  "..."
}
```

The field `event[:name]` contains event name (same as routing key).
The fields `foo`, `bar`, `qux` (just for example) are fields which carry useful information.

## Format of `model.deposit.created` event

```ruby
event: {
  name: "model.deposit.created",
  record: {
    tid:                      "TID9493F6CD41",
    user: {
      uid:                    "ID092B2AF8E87",
      email:                  "john@doe.com"
    },
    uid:                      "ID092B2AF8E87",
    currency:                 "btc",
    amount:                   "0.0855",
    state:                    "submitted",
    created_at:               "2018-04-12T17:16:06+03:00",
    updated_at:               "2018-04-12T17:16:06+03:00",
    completed_at:             nil,
    blockchain_address:       "n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7W",
    blockchain_txid:          "c37ae1677c4c989dbde9ac22be1f3ff3ac67ed24732a9fa8c9258fdff0232d72",
    blockchain_confirmations: 1
  }
}
```

| Field      | Description                         |
| ---------- | ----------------------------------- |
| `record`   | The up-to-date deposit attributes.  |

## Format of `model.deposit.updated` event

```ruby
event: {
  name: "model.deposit.updated",
  record: {
    tid:                      "TID9493F6CD41",
    user: {
      uid:                    "ID092B2AF8E87",
      email:                  "john@doe.com"
    },
    uid:                      "ID092B2AF8E87",
    currency:                 "btc",
    amount:                   "0.0855",
    state:                    "accepted",
    created_at:               "2018-04-12T17:16:06+03:00",
    updated_at:               "2018-04-12T18:46:57+03:00",
    completed_at:             "2018-04-12T18:46:57+03:00",
    blockchain_address:       "n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7W",
    blockchain_txid:          "c37ae1677c4c989dbde9ac22be1f3ff3ac67ed24732a9fa8c9258fdff0232d72",
    blockchain_confirmations: 7
  },
  changes: {
    state:                    "submitted",
    completed_at:             nil,
    blockchain_confirmations: 1,
    updated_at:               "2018-04-12T17:16:06+03:00"
  }
}
```

| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `record`   | The up-to-date deposit attributes.               |
| `changes`  | The changed deposit attributes and their values. |

## Format of `model.withdraw.created` event

```ruby
event: {
  name: "model.withdraw.created",
  record: {
    tid:             "TID892F29F094",
    user: {
      uid:           "ID092B2AF8E87",
      email:         "john@doe.com"
    },
    uid:             "ID092B2AF8E87",
    rid:             "0xdA35deE8EDDeAA556e4c26268463e26FB91ff74f",
    currency:        "eth",
    amount:          "4.5485",
    fee:             "0.0015",
    state:           "prepared",
    created_at:      "2018-04-12T18:52:16+03:00",
    updated_at:      "2018-04-12T18:52:16+03:00",
    completed_at:    nil,
    blockchain_txid: nil
  }
}
```

| Field      | Description                          |
| ---------- | ------------------------------------ |
| `record`   | The up-to-date withdraw attributes.  |

## Format of `model.withdraw.updated` event

```ruby
event: {
  name: "model.withdraw.updated",
  record: {
    tid:             "TID892F29F094",
    user: {
      uid:           "ID092B2AF8E87",
      email:         "john@doe.com"
    },
    uid:             "ID092B2AF8E87",
    rid:             "0xdA35deE8EDDeAA556e4c26268463e26FB91ff74f",
    currency:        "eth",
    amount:          "4.5485",
    fee:             "0.0015",
    state:           "succeed",
    created_at:      "2018-04-12T18:52:16+03:00",
    updated_at:      "2018-04-12T18:56:23+03:00",
    completed_at:    "2018-04-12T18:56:23+03:00",
    blockchain_txid: "0x9c34d1750e225a95938f9884e857ab6f55eedda43b159d13abf773fe6a916164"
  },
  changes: {
    state:           "processing",
    updated_at:      "2018-04-12T18:55:39+03:00",
    completed_at:    "2018-04-12T18:55:39+03:00",
    blockchain_txid: nil
  }
}
```

| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `record`   | The up-to-date withdraw attributes.               |
| `changes`  | The changed withdraw attributes and their values. |

## Format of `model.account.created` event

```ruby
event: {
  name: "model.account.created",
  record: {
    id:                      "1",
    member_id:               "2",
    currency_id:             "btc",
    balance:                 "0",
    locked:                  "0",
    created_at:               "2018-04-12T17:16:06+03:00",
    updated_at:               "2018-04-12T17:16:06+03:00",
  }
}
```

| Field      | Description                         |
| ---------- | ----------------------------------- |
| `record`   | The up-to-date account attributes.  |

## Format of `model.account.updated` event

```ruby
event: {
  name: "model.account.updated",
  record: {
    id:                      "1",
    member_id:               "2",
    currency_id:             "btc",
    balance:                 "1",
    locked:                  "0",
    created_at:               "2018-04-12T17:16:06+03:00",
    updated_at:               "2018-04-12T17:17:06+03:00",
  },
  changes: {
    balance:                  "0",
    updated_at:               "2018-04-12T17:16:06+03:00"
  }
}
```

| Field      | Description                                      |
| ---------- | ------------------------------------------------ |
| `record`   | The up-to-date account attributes.               |
| `changes`  | The changed account attributes and their values. |

## Format of `market.btcusd.order_created` event

Buy 14 BTC for 0.42 USD (0.03 USD per BTC).

```ruby
event: {
  name:                   "market.btcusd.order_created",
  market:                 "btcusd",
  type:                   "buy",
  trader_uid:             "ID022H2NF6E87",
  income_unit:            "btc",
  income_fee_type:        "relative",
  income_fee_value:       "0.0015",
  outcome_unit:           "usd",
  outcome_fee_type:       "relative",
  outcome_fee_value:      "0.0",
  initial_income_amount:  "14.0",
  current_income_amount:  "14.0",
  initial_outcome_amount: "0.42",
  current_outcome_amount: "0.42",
  strategy:               "limit",
  price:                  "0.03",
  state:                  "open",
  trades_count:           0,
  created_at:             "2018-05-07T02:12:28Z"
}
```

## Format of `market.btcusd.order_updated` event

Sell 100 BTC for 3 USD (0.03 USD per BTC).

```ruby
event: {
  name:                    "market.btcusd.order_updated",
  market:                  "btcusd",
  type:                    "sell",
  trader_uid:              "ID092B2AF8E87",
  income_unit:             "usd",
  income_fee_type:         "relative",
  income_fee_value:        "0.0015",
  outcome_unit:            "btc",
  outcome_fee_type:        "relative",
  outcome_fee_value:       "0.0",
  initial_income_amount:   "3.0",
  current_income_amount:   "2.4",
  previous_income_amount:  "3.0",
  initial_outcome_amount:  "100.0",
  current_outcome_amount:  "80.0",
  previous_outcome_amount: "100.0",
  strategy:                "limit",
  price:                   "0.03",
  state:                   "open",
  trades_count:            1,
  created_at:              "2018-05-07T02:12:28Z",
  updated_at:              "2018-05-08T10:13:13Z"
}
```

## Format of `market.btcusd.order_canceled` event

Sell 100 BTC for 3 USD (0.03 USD per BTC).

```ruby
event: {
  name:                    "market.btcusd.order_canceled",
  market:                  "btcusd",
  type:                    "sell",
  trader_uid:              "ID092B2AF8E87",
  income_unit:             "usd",
  income_fee_type:         "relative",
  income_fee_value:        "0.0015",
  outcome_unit:            "btc",
  outcome_fee_type:        "relative",
  outcome_fee_value:       "0.0",
  initial_income_amount:   "3.0",
  current_income_amount:   "3.0",
  initial_outcome_amount:  "100.0",
  current_outcome_amount:  "100.0",
  strategy:                "limit",
  price:                   "0.03",
  state:                   "canceled",
  trades_count:            0,
  created_at:              "2018-05-07T02:12:28Z",
  canceled_at:             "2018-05-08T10:13:13Z"
}
```

## Format of `market.btcusd.order_completed` event

Sell 100 BTC for 3 USD (0.03 USD per BTC).

```ruby
event: {
  name:                    "market.btcusd.order_completed",
  market:                  "btcusd",
  type:                    "sell",
  trader_uid:              "ID092B2AF8E87",
  income_unit:             "usd",
  income_fee_type:         "relative",
  income_fee_value:        "0.0015",
  outcome_unit:            "btc",
  outcome_fee_type:        "relative",
  outcome_fee_value:       "0.0",
  initial_income_amount:   "3.0",
  current_income_amount:   "0.0",
  previous_income_amount:  "3.0",
  initial_outcome_amount:  "100.0",
  current_outcome_amount:  "0.0",
  previous_outcome_amount: "100.0",
  strategy:                "limit",
  price:                   "0.03",
  state:                   "completed",
  trades_count:            1,
  created_at:              "2018-05-07T02:12:28Z",
  completed_at:            "2018-05-07T17:32:09Z"
}
```

## Format of `market.btcusd.trade_completed` event

```ruby
event: {
  name:                  "market.btcusd.trade_completed",
  market:                "btcusd",
  price:                 "0.03",
  buyer_uid:             "ID022H2NF6E87",
  buyer_income_unit:     "btc",
  buyer_income_amount:   "14",
  buyer_income_fee:      "0.021",
  buyer_outcome_unit:    "usd",
  buyer_outcome_amount:  "0.42",
  buyer_outcome_fee:     "0.0",
  seller_uid:            "ID092B2AF8E87",
  seller_income_unit:    "usd",
  seller_income_amount:  "0.42",
  seller_income_fee:     "0.00063",
  seller_outcome_unit:   "btc",
  seller_outcome_amount: "14.0",
  seller_outcome_fee:    "0.0",
  completed_at:          "2018-05-07T17:32:09Z"
}
```

## Producing events using Ruby

```ruby
require "bunny"

def generate_jwt(jwt_payload)
  Kernel.abort "Please, see «Overview of RabbitMQ message» for implementation guide."
end

Bunny.run host: "localhost", port: 5672, username: "guest", password: "guest" do |session|
  channel     = session.channel
  exchange    = channel.direct("peatio.events.model")
  jwt_payload = {
    iss:   "peatio",
    jti:   SecureRandom.uuid,
    iat:   Time.now.to_i,
    exp:   Time.now.to_i + 60,
    event: {
      name: "model.deposit.created",
      record: {
        tid:                      "TID9493F6CD41",
        user: {
          uid: "ID092B2AF8E87",
          email: "john@doe.com"
        },
        uid:                      "ID092B2AF8E87",
        currency:                 "btc",
        amount:                   "0.0855",
        state:                    "submitted",
        created_at:               "2018-04-12T17:16:06+03:00",
        updated_at:               "2018-04-12T17:16:06+03:00",
        completed_at:             nil,
        blockchain_address:       "n1Ytj6Hy57YpfueA2vtmnwJQs583bpYn7W",
        blockchain_txid:          "c37ae1677c4c989dbde9ac22be1f3ff3ac67ed24732a9fa8c9258fdff0232d72",
        blockchain_confirmations: 1
      }
    }
  }
  exchange.publish(generate_jwt(jwt_payload), routing_key: "deposit.created")
end
```

IMPORTANT: Don't forget to implement the logic for JWT exception handling!

## Producing events using `rabbitmqadmin`

`rabbitmqadmin publish routing_key=deposit.created payload=JWT exchange=peatio.events.model`

Don't forget to pass environment variable `JWT`.

## Consuming events using Ruby

```ruby
require "bunny"

def verify_jwt(jwt_payload)
  Kernel.abort "Please, see «Overview of RabbitMQ message» for implementation guide."
end

Bunny.run host: "localhost", port: 5672, username: "guest", password: "guest" do |session|
  channel  = session.channel
  exchange = channel.direct("peatio.events.model")
  queue    = channel.queue("", auto_delete: true, durable: true, exclusive: true)
                    .bind(exchange, routing_key: "deposit.updated")
  queue.subscribe manual_ack: true, block: true do |delivery_info, metadata, payload|
    Kernel.puts verify_jwt(JSON.parse(payload)).fetch(:event)
    channel.ack(delivery_info.delivery_tag)
  rescue => e
    channel.nack(delivery_info.delivery_tag, false, true)
  end
end
```

IMPORTANT: Don't forget to implement the logic for JWT exception handling!

