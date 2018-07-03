# Peatio daemons

## amqp:deposit_coin

This daemon receives request for processing and validating deposit.

## amqp:deposit_coin_address

This daemon creates new addresses for you.

## amqp:market_ticker

This daemon updates market ticker when some orders or trades are created / updated.

## amqp:matching

This daemon matches orders and sends them to amqp:trade_executor.

## amqp:order_processor

This daemon processes cancelation of orders.

## amqp:pusher_market

This daemon delivers new trade to Pusher.

## amqp:pusher_member

This daemon delivers events to private member Pusher channel.

## amqp:slave_book

This daemon keeps copy of in-memory orderbook from amqp:matching and updates various data stored in Redis which is needed for trading UI.

## amqp:withdraw_coin

This daemon performs withdraw.

## coins

This daemon monitors blockchain for incoming deposits and forwards them to amqp:deposit_coin.

## global_state

This daemon send orderbook to Pusher every 5 seconds.

## k

This daemon updates k-lines every 15 seconds.

## payment_transaction

This daemon updates number of incoming deposits confirmations and updates the balance.

## withdraw_audit

This daemon validates withdraws and sends them to amqp:withdraw_coin.

## amqp:trade_executor

This daemon performs partial or full fullfilment or two orders.
