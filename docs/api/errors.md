# Peatio Member API Errors

## Shared errors

| Code                    | Description                         |
| ----------------------- | ----------------------------------- |
| `jwt.decode_and_verify` | Impossible to decode and verify JWT |
| `record.not_found`      | Record Not found                    |
| `server.internal_error` | Internal Server Error               |

## Account module

| Code                                    | Description                                    |
| --------------------------------------- | ---------------------------------------------- |
| `account.currency.doesnt_exist`         | **Currency** doesn't exist in database         |
| `account.balance.missing_currency`      | Parameter **currency** is missing              |
| `account.deposit.missing_currency`      | Parameter **currency** is missing              |
| `account.deposit.invalid_state`         | Deposit **state** is not valid                 |
| `account.deposit.non_integer_limit`     | Parameter **limit** should be integer          |
| `account.deposit.invalid_limit`         | Parameter **limit** is not valid               |
| `account.deposit.non_positive_page`     | Parameter **page** should be positive number   |
| `account.deposit.empty_txid`            | Parameter **txid** is empty                    |
| `account.withdraw.missing_txid`         | Parameter **txid** is missing                  |
| `account.deposit.not_permitted`         | Pass the corresponding verification steps to **deposit funds** |
| `account.withdraw.non_integer_limit`    | Parameter **limit** should be integer          |
| `account.withdraw.invalid_limit`        | Parameter **limit** is not valid               |
| `account.withdraw.non_positive_page`    | Parameter **page** should be positive number   |
| `account.withdraw.non_integer_otp`      | Parameter **otp** should be integer            |
| `account.withdraw.empty_otp`            | Parameter **otp** is empty                     |
| `account.withdraw.missing_otp`          | Parameter **otp** is missing                   |
| `account.withdraw.missing_rid`          | Parameter **rid** is missing                   |
| `account.withdraw.missing_amount`       | Parameter **amount** is missing                |
| `account.withdraw.missing_currency`     | Parameter **currency** is missing              |
| `account.withdraw.empty_rid`            | Parameter **rid** is empty                     |
| `account.withdraw.non_decimal_amount`   | Parameter **amount** should be decimal         |
| `account.withdraw.non_positive_amount`  | Parameter **amount** should be positive number |
| `account.withdraw.insufficient_balance` | Account **balance** is insufficient            |
| `account.withdraw.invalid_amount`       | Parameter **amount** is not valid              |
| `account.withdraw.create_error`         | Failed to create withdraw                      |
| `account.withdraw.invalid_otp`          | Parameter **otp** is not valid                 |
| `account.withdraw.disabled_api`         | Withdrawal API is disabled                     |
| `account.withdraw.not_permitted`        | Pass the corresponding verification steps to **withdraw funds** |
| `account.withdraw.too_long_note`        | Parameter **note** is too long |
| `account.deposit_address.invalid_address_format`             | Invalid parameter for deposit address format |
| `account.deposit_address.doesnt_support_cash_address_format` | Currency doesn't support cash address format |

## Market module

| Code                                         | Description                                                      |
| -------------------------------------------- | ---------------------------------------------------------------- |
| `market.account.insufficient_balance`        | Account balance is insufficient                                  |
| `market.market.doesnt_exist_or_not_enabled`  | **Market** doesn't exist in database or currently disabled/hidden|
| `market.order.insufficient_market_liquidity` | Insufficient market liquidity                                    |
| `market.order.invalid_volume_or_price`       | Order **volume** or **price** is invalid for selected market     |
| `market.order.create_error`                  | Failed to create order                                           |
| `market.order.cancel_error`                  | Failed to cancel order                                           |
| `market.order.market_order_price`            | Market order doesn't have **price**                              |
| `market.order.invalid_state`                 | Parameter **state** is not valid                                 |
| `market.order.invalid_limit`                 | Parameter **limit** is not valid                                 |
| `market.order.non_integer_limit`             | Parameter **limit** should be integer                            |
| `market.order.invalid_order_by`              | Parameter **order_by** is not valid                              |
| `market.order.invalid_ord_type`              | Parameter **ord_type** is not valid                              |
| `market.order.invalid_type`                  | Parameter **type** is not valid                                  |
| `market.order.invalid_side`                  | Parameter **side** is not valid                                  |
| `market.order.missing_market`                | Parameter **market** is missing                                  |
| `market.order.missing_side`                  | Parameter **side** is missing                                    |
| `market.order.missing_volume`                | Parameter **volume** is missing                                  |
| `market.order.missing_price`                 | Parameter **price** is missing                                   |
| `market.order.missing_id`                    | Parameter **id** is missing                                      |
| `market.order.non_decimal_volume`            | Parameter **volume** should be decimal                           |
| `market.order.non_positive_volume`           | Parameter **volume** should be positive number                   |
| `market.order.invalid_type`                  | Parameter **type** is not valid                                  |
| `market.order.non_decimal_price`             | Parameter **price** should be decimal                            |
| `market.order.non_positive_price`            | Parameter **price** should be positive number                    |
| `market.order.non_integer_id`                | Parameter **id** should be integer                               |
| `market.order.empty_id`                      | Parameter **id** is empty                                        |
| `market.trade.non_integer_limit`             | Parameter **limit** should be integer                            |
| `market.trade.invalid_limit`                 | Parameter **limit** is not valid                                 |
| `market.trade.empty_page`                    | Parameter **page** is empty                                      |
| `market.trade.non_integer_time_from`         | Parameter **time_from** should be integer                        |
| `market.trade.empty_time_from`               | Parameter **time_from** is empty                                 |
| `market.trade.non_integer_time_to`           | Parameter **time_to** should be integer                          |
| `market.trade.empty_time_to_`                | Parameter **time_to** is empty                                   |
| `market.trade.invalid_order_by`              | Parameter **order_by** is not valid                              |
| `market.trade.not_permitted`                 | Pass the corresponding verification steps to **enable trading**  |

## Public module

| Code                                      | Description                                  |
| ----------------------------------------- | ---------------------------------------------|
| `public.currency.doesnt_exist`            | **Currency** doesn't exist in database       |
| `public.currency.invalid_type`            | **Currency** type is not valid               |
| `public.currency.missing_id`              | Parameter **id** is missing                  |
| `public.market.missing_market`            | Parameter **market** is missing              |
| `public.market.doesnt_exist`              | **Market** doesn't exist in database         |
| `public.order_book.non_integer_ask_limit` | Parameter **ask_limit** should be integer    |
| `public.order_book.invalid_ask_limit`     | Parameter **ask_limit** is not valid         |
| `public.order_book.non_integer_bid_limit` | Parameter **bid_limit** should be integer    |
| `public.order_book.invalid_bid_limit`     | Parameter **bid_limit** is not valid         |
| `public.trade.invalid_limit`              | Parameter **limit** is not valid             |
| `public.trade.non_integer_limit`          | Parameter **limit** should be integer        |
| `public.trade.non_positive_page`          | Parameter **page** should be positive number |
| `public.trade.non_integer_timestamp`      | Parameter **timestamp** should be integer    |
| `public.trade.invalid_order_by`           | Parameter **order_by** is not valid          |
| `public.market_depth.non_integer_limit`   | Parameter **limit** should be integer        |
| `public.market_depth.invalid_limit`       | Parameter **limit** is not valid             |
| `public.k_line.non_integer_period`        | Parameter **period** should be integer       |
| `public.k_line.invalid_period`            | Parameter **period** is not valid            |
| `public.k_line.non_integer_time_from`     | Parameter **time_from** should be integer    |
| `public.k_line.empty_time_from`           | Parameter **time_from** is empty             |
| `public.k_line.non_integer_time_to`       | Parameter **time_to** should be integer      |
| `public.k_line.empty_time_to`             | Parameter **time_to** is empty               |
| `public.k_line.non_integer_limit`         | Parameter **limit** should be integer        |
| `public.k_line.invalid_limit`             | Parameter **limit** is not valid             |
