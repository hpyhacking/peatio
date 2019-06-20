| Blockchain                   |   Superadmin | Admin  |  Accountant |Compliance | Technical| Support | Member| Broker| Trader|
| ----------------------       |:------------:|:------:|:-----------:|:---------:|:--------:|:-------:|:-----:|:-----:|------:|
| Create blockchain            | RW           |   RW   | NO          | NO        | RW       | NO      | NO    |NO     |NO     |
| Change blockchain field      | RW           |   RW   | NO          | NO        | RW       | NO      | NO    |NO     |NO     |
| **Currencies**               |              |        |             |           |          |         |       |
|Create currency               | RW           |   RW   | NO          | NO        | RW       | NO      | NO    |NO     |NO     |
|Change currency field         | RW           |   RW   | NO          | NO        | RW       | NO      | NO    |NO     |NO     |
|**Markets**                   |              |        |             |           |          |         |       |
|Create market                 | RW           |   RW   | NO          | NO        | RW       | NO      | NO    |NO     |NO     |
|Change market field           | RW           |   RW   | NO          | NO        | RW       | NO      | NO    |NO     |NO     |
|**Wallets**                   |              |        |             |           |          |         |       |
|Create wallet                 | RW           |   RW   | NO          | NO        | RW       | NO      | NO    |NO     |NO     |
|Change wallet field           | RW           |   RW   | NO          | NO        | RW       | NO      | NO    |NO     |NO     |
|**Deposits**                  |              |        |             |           |          |         |       |
|Read user's deposits          | RO           |   RO   | RO          | RO        | RO       | RO      | NO    |NO     |NO     |
|Collect deposits              | RW           |   RW   | NO          | NO        | NO       | NO      | NO    |NO     |NO     |
|Create fiat deposit           | RW           |   RW   | RO          | NO        | NO       | NO      | NO    |NO     |NO     |
|Accept fiat deposit           | RW           |   RW   | NO          | NO        | NO       | NO      | NO    |NO     |NO     |
|Reject fiat deposit           | RW           |   RW   | NO          | NO        | NO       | NO      | NO    |NO     |NO     |
|**Withdraws**                 |              |        |             |           |          |         |       |
|Read withdrawals              | RW           |   RW   | RO          | RO        | RO       | RO      | NO    |NO     |NO     |
|Accept withdrawals            | RW           |   RW   | NO          | NO        | NO       | NO      | NO    |NO     |NO     |
|Reject withdrawals            | RW           |   RW   | NO          | NO        | NO       | NO      | NO    |NO     |NO     |
|**Members**                   |              |        |             |           |          |         |       |
|Read user's balances          |  RW          |   RO   | RO          | RO        | RO       | RO      | NO    |NO     |NO     |
|Read user's deposit address   |  RW          |   RO   | RO          | RO        | RO       | RO      | NO    |NO     |NO     |
|**Operations**                |              |        |             |           |          |         |       |
|Read platform's operations    |  RW          |   RW   | RO          | RO        | RO       | RO      | NO    |NO     |NO     |
|**Accounting**                |              |        |             |           |          |         |       |
|Read exchange balance sheet   |  RW          |   RW   | RO          | RO        | NO       | RO      | NO    |NO     |NO     |
|Read exchange income statement|  RW          |   RW   | RO          | RO        | NO       | RO      | NO    |NO     |NO     |
