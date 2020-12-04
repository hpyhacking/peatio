## Trader PnL calculation

This doc describes how you can calculate a trader’s total P&L

| Term               | Definition                                                   |
| ------------------ | ------------------------------------------------------------ |
| PnL currency       | The currency into which the entries are converted to.        |
| Currency           | Trader income or outcome currency                            |
| Total Credit       | Sum of incomes of the trader in the currency (without fees)  |
| Total Credit Fees  | Sum of fees applied to incomes of the trader in the currency |
| Total Credit Value | (Total Credit + Total Credit Fees) estimated in pnl currency using the latest market price |
| Total Debit        | Sum of outcomes of the trader in the currency (without fees) |
| Total Debit Fees   | Sum of fees applied to outcomes of the trader in the currency |
| Total Debit Value  | (Total Debit + Total Debit Fees) estimated in pnl currency   |
| Average Buy Price  | Total Credit Value / (Total Credit + Total Credit Fees)      |
| Average Sell Price | Total Debit Value / (Total Debit + Total Debit Fees)         |

### Configuration

To enable the PnL calculation for traders you need to setup at least one destination currency in the PNL_CURRENCIES variable.

| Environment Variable | Example                                                      | Description                                                  |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| PNL_CURRENCIES       | usd,btc                                                      | List of pnl currencies                                       |
| CONVERSION_PATHS     | usd/krw:_usdt/usd,usdt/krw this will convert usd to krw using the last price of markets usd/usdt (reversed) and usd/krw | By default conversions are made using the direct market (BTC to USD use latest market price of btc/usd). If a direct conversion market is missing you can specify a conversion path setting this variable. Several paths can be defined with semi-colon (;) separation. |
| PNL_EXCLUDE_ROLES    | maker,broker                                                 | Skip PnL calculation for users with the following roles      |


### Formulas
#### Calculate user Realized PNL
##### For one currency
-----
###### Realized PNL Value = Total Debit Value * (Average Sell Price - Average Buy Price) / Average Sell Price
-----
#### Calculate user Unrealized PNL
##### For one currency
-----
###### Asset Current Value = Balance * Last Market Price
###### Asset Average Buy Value = Balance * Average Buy Price
###### Unrealized PNL Value =  Asset Current Value - Asset Average Buy Value
###### Unrealized PNL Percentage = (100 * Unrealized PNL Value) / Asset Average Buy Value
-----
#### Calculate user Total PNL
##### For one currency
-----
###### Total PNL = Realized PNL + Unrealized PNL
-----
#### Total user assets PNL
-----
###### Total Asset Average Value =  SUM(Asset Average Buy Value)
###### Total Asset Current Value = SUM(Asset Current Value)
###### Total PNL Value = Total Asset Current Value - Total Asset Average Value
###### Total PNL Percentage = (100 * Total PNL Value) / Total Asset Average Value
-----
#### 1) Initial State


|Currency| Balance |Total Credit | Total Credit Fees | Total Credit Value | Total Debit | Total Debit Fees | Total Debit Value  |  Average Buy Price | Average Sell Price | Realized PNL | Unrealized PNL| Total PNL | Average PNL Price |Total PNL Value|
|---|---|---|---|---|---|---| ---|---|---|---|---|---|---|---|
| BTC | 0 | 0  | 0 | 0  | 0  | 0 | 0 | 0 | 0| 0| 0| 0| 0 | 0|

#### 2) Deposit 3 BTC, Portfolio Currency = ETH, Last Market Price (BTC/ETH) = 10 000

|Currency| Balance |Total Credit | Total Credit Fees | Total Credit Value | Total Debit | Total Debit Fees | Total Debit Value  |  Average Buy Price | Average Sell Price | Realized PNL | Unrealized PNL| Total PNL | Average PNL Price |Total PNL Value|
|---|---|---|---|---|---|---| ---|---|---|---|---|---|---|---|
| BTC | 2.994000 | 2.994000  | 0.006000 | 30 000  | 0  | 0 | 0 | 10 000| 0| 0| 0| 0| 10000 | 29940 |
-------
###### Average Buy Price = 30000 / (2.994000 + 0.006000) = 10000
###### Total PNL Value = Total Credit * Average Buy Price -Total Debit Value = 2.994000 * 10 000 - 0 = 29940
###### Average PNL Price = Total PNL Value / Balance = 29940 / 2.994000 = 10000
------
#### 3) Sell 1 BTC, Portfolio Currency = ETH, Last Market Price (BTC/ETH) = 9000

|Currency| Balance |Total Credit | Total Credit Fees | Total Credit Value | Total Debit | Total Debit Fees | Total Debit Value  |  Average Buy Price | Average Sell Price | Realized PNL | Unrealized PNL| Total PNL | Average PNL Price |Total PNL Value|
|---|---|---|---|---|---|---| ---|---|---|---|---|---|---|---|
| BTC| 1.994000 | 2.994000 | 0.006000| 30 000  | 1 | 0 | 9000 | 10 000 | 9000 | -1000| -1994| -2994 | 10501.5045135 | 20940 |
------
###### Average Sell Price = 9000 / (1 + 0.006000) = 9000
###### Realized PNL = Total Debit Value * (Average Sell Price - Average Buy Price) / Average Sell Price = 9000 * (9000 - 10 000) / 9000 = -1000
###### Unrealized PNL = Balance * Last Market Price (BTC/ETH) - Balance * Average Buy Price = 1.994000 * 9000 - 1.994000 * 10 000 = - 1994
###### Total PNL = Realized PNL + Unrealized PNL = -1000 + (-1994) = -2994
###### Total PNL Value = Total Credit * Average Buy Price - Total Debit Value = 2.994000 * 10 000 - 9000 = 20940
###### Average PNL Price = Total PNL Value / Balance = 20940 / 1.994000 = 10501.5045135
-----
