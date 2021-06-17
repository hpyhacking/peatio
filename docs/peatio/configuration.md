# Peatio environments configuration
This document provides description of available configuration through the environment.

### General configuration
| Environment variable          | Default value | Possible values | Description                                                  |
| ----------------------------- | ------------- | --------------- | ------------------------------------------------------------ |
| `PEATIO_DEPOSIT_FUNDS_LOCKED` | false         | `true`, `false` | When turned on (`true`) user funds will be locked on deposit, and unlocked once the collection of this deposit succeed |
| `PEATIO_PLATFORM_CURRENCY`    | `usdt` | any valid currency code | System use platform currency to estimate min deposit amount, withdraw fee, min withdraw amount of blockchain_currency if auto update configuration enabled|
| `PEATIO_PRICE_FETCH_PERIOD_TIME`  | 300 | any valid integer | Period of time for recalculation of min deposit amount, withdraw fee, min withdraw amount due to latest market price if auto update configuration enabled |
