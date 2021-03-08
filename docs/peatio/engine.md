# ENGINES

Engines in Peatio represent market's matching engine settings.

| column           | Desc                                                 |
| ---------------- | ---------------------------------------------------- |
| id               | an unique identifier in database                     |
| name             | human-readable description                           |
| driver           | More about driver in DRIVERS section                 |
| uid              | User's UID for upstream markets (more in UPSTREAM)  |
| url              | URL for upstream                                     |
| key_encrypted    | apikey kid for upstream                              |
| secret_encrypted | apikey secret for upstream                           |
| data_encrypted   | can hold any engine-specific key-value configuration |
| state            | Either online or offline                             |

Every market belongs to one of defined engines and every engine should have one of supported drivers.

## DRIVERS

Drivers can be divided into two groups - Local or Upstream.

Supported local drivers are peatio and finex-spot.

Peatio comes with peatio driver available only.

Upstream drivers are supported in finex trading engine.

## UPSTREAM

Upstream is a remote platform you can connect to to use them as liquidity provider for your platform.

To setup upstream market, you need to create an upstream engine:

```ruby
engine = Engine.create(name: "BitFinex", driver: "bitfinex", uid: "UID", key: "KID", secret: "SECRET", url: "wss://api.bitfinex.com/ws/2", data: {"rest": "http://api-pub.bitfinex.com/ws/2", "websocket": "wss://api-pub.bitfinex.com/ws/2", "trade_proxy"=>true, "orderbook_proxy"=>true})
```

`UID` is an 'upstream' user UID on **your platform**. When you submit an order to the upstream market and get a trade on remote platform, the trade will be recorded as a trade between you and this user.

`KID` and `SECRET` are your **remote platform** credentials.

`data` field should contain a configuration for trade and orderbook proxy. Peatio Upstream daemon will connect to the remote platform via `rest` and `websocket` params in data and will forward latest trades and incremental orderbook updates to your platform.

And ***do not forget to deposit funds to remote platform*** :)

:warning: When using an upstream engine, the market configuration needs to contain the target market id on the upstream (`target` field in `data` column).
For example, for BTC/USDT market you need to configure `BTCUST` for Bitfinex in `market.data['target']`.

You can add or modify a market target from the rails console like that:

```ruby
  Market.find("btcusdt").update(data: {"target"=>"BTCUST"})
```
