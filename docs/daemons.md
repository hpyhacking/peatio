# Peatio daemons

## amqp:deposit_collection

This daemon transfer incoming deposits from deposit wallet to withdraw wallets (hot, warm, cold).

## amqp:deposit_collection_fees

This daemon transfer fees for deposit collection paying and send deposit_collection request to amqp:deposit_collection.

## amqp:deposit_coin_address

This daemon creates new addresses for you.

## amqp:market_ticker

This daemon updates market ticker when some orders or trades are created / updated.

## amqp:matching

This daemon matches orders and sends them to amqp:trade_executor.

## amqp:order_processor

This daemon processes cancelation of orders.

## amqp:pusher_market

This daemon delivers new trade to Ranger.

## amqp:pusher_member

This daemon delivers events to private member Ranger channel.

## amqp:slave_book

This daemon keeps copy of in-memory orderbook from amqp:matching and updates various data stored in Redis which is needed for trading UI.

## amqp:withdraw_coin

This daemon performs withdraw.

## blockchain

This daemon monitors blockchain for incoming deposits and withdrawal and updates their state on the database.

## global_state

This daemon send orderbook to Ranger every 5 seconds.

## k

This daemon updates k-lines every 15 seconds.

## withdraw_audit

This daemon validates withdrawals and sends them to amqp:withdraw_coin.

## amqp:trade_executor

This daemon performs partial or full fullfilment of two orders.
