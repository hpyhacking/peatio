# Peatio Management API v2
Management API is server-to-server API with high privileges.

## Version: 2.6.0

**Contact information:**  
openware.com  
<https://www.openware.com>
hello@openware.com  

**License:** <https://github.com/openware/peatio/blob/master/LICENSE.md>

### /api/v2/management/peatio/beneficiaries

#### POST
##### Description

Create new beneficiary

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | Beneficiary currency code. | Yes | string |
| name | formData | Human rememberable name which refer beneficiary. | Yes | string |
| description | formData | Human rememberable description which refer beneficiary. | No | string |
| data | formData | Beneficiary data in JSON format | Yes | json |
| uid | formData | The shared user ID. | Yes | string |
| state | formData | Defines either beneficiary active - user can use it to withdraw moneyor pending - requires beneficiary activation with pin. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Create new beneficiary | [Beneficiary](#beneficiary) |

### /api/v2/management/peatio/beneficiaries/list

#### POST
##### Description

Get list of user beneficiaries

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| currency | formData | Beneficiary currency code. | No | string |
| state | formData | Defines either beneficiary active - user can use it to withdraw moneyor pending - requires beneficiary activation with pin. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Get list of user beneficiaries | [Beneficiary](#beneficiary) |

### /api/v2/management/peatio/accounts/balances

#### POST
##### Description

Queries the non-zero balance accounts for the given currency.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency code. | Yes | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of accounts per page (defaults to 100, maximum is 1000). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Queries the non-zero balance accounts for the given currency. | [Balance](#balance) |

### /api/v2/management/peatio/accounts/balance

#### POST
##### Description

Queries the account balance for the given UID and currency.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| currency | formData | The currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Queries the account balance for the given UID and currency. | [Balance](#balance) |

### /api/v2/management/peatio/deposits/state

#### PUT
##### Description

Allows to load money or cancel deposit.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The shared transaction ID. | Yes | string |
| state | formData | The new state to apply. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Allows to load money or cancel deposit. | [Deposit](#deposit) |

### /api/v2/management/peatio/deposits/new

#### POST
##### Description

Creates new fiat deposit with state set to «submitted». Optionally pass field «state» set to «accepted» if want to load money instantly. You can also use PUT /fiat_deposits/:id later to load money or cancel deposit.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| tid | formData | The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied. | No | string |
| currency | formData | The currency code. | Yes | string |
| amount | formData | The deposit amount. | Yes | double |
| state | formData | The state of deposit. | No | string |
| transfer_type | formData | Deposit transfer type | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new fiat deposit with state set to «submitted». Optionally pass field «state» set to «accepted» if want to load money instantly. You can also use PUT /fiat_deposits/:id later to load money or cancel deposit. | [Deposit](#deposit) |

### /api/v2/management/peatio/deposits/get

#### POST
##### Description

Returns deposit by TID.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The transaction ID. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns deposit by TID. | [Deposit](#deposit) |

### /api/v2/management/peatio/deposits

#### POST
##### Description

Returns deposits as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | No | string |
| currency | formData | The currency code. | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of deposits per page (defaults to 100, maximum is 1000). | No | integer |
| state | formData | The state to filter by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns deposits as paginated collection. | [Deposit](#deposit) |

### /api/v2/management/peatio/withdraws/action

#### PUT
##### Summary

Performs action on withdraw.

##### Description

«process» – system will lock the money, check for suspected activity, validate recipient address, and initiate the processing of the withdraw. «cancel»  – system will mark withdraw as «canceled», and unlock the money.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The shared transaction ID. | Yes | string |
| action | formData | The action to perform. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Performs action on withdraw. | [Withdraw](#withdraw) |

### /api/v2/management/peatio/withdraws/new

#### POST
##### Summary

Creates new withdraw.

##### Description

Creates new withdraw. The behaviours for fiat and crypto withdraws are different. Fiat: money are immediately locked, withdraw state is set to «submitted», system workers will validate withdraw later against suspected activity, and assign state to «rejected» or «accepted». The processing will not begin automatically. The processing may be initiated manually from admin panel or by PUT /management_api/v1/withdraws/action. Coin: money are immediately locked, withdraw state is set to «submitted», system workers will validate withdraw later against suspected activity, validate withdraw address and set state to «rejected» or «accepted». Then in case state is «accepted» withdraw workers will perform interactions with blockchain. The withdraw receives new state «processing». Then withdraw receives state either «confirming» or «failed».Then in case state is «confirming» withdraw confirmations workers will perform interactions with blockchain.Withdraw receives state «succeed» when it receives minimum necessary amount of confirmations.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| tid | formData | The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied. | No | string |
| rid | formData | The beneficiary ID or wallet address on the Blockchain. | No | string |
| beneficiary_id | formData | ID of Active Beneficiary belonging to user. | No | string |
| currency | formData | The currency code. | Yes | string |
| amount | formData | The amount to withdraw. | Yes | double |
| note | formData | The note for withdraw. | No | string |
| action | formData | The action to perform. | No | string |
| transfer_type | formData | Withdraw transfer type | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new withdraw. | [Withdraw](#withdraw) |

### /api/v2/management/peatio/withdraws/get

#### POST
##### Description

Returns withdraw by ID.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The shared transaction ID. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns withdraw by ID. | [Withdraw](#withdraw) |

### /api/v2/management/peatio/withdraws

#### POST
##### Description

Returns withdraws as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | No | string |
| currency | formData | The currency code. | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of objects per page (defaults to 100, maximum is 1000). | No | integer |
| state | formData | The state to filter by. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns withdraws as paginated collection. | [Withdraw](#withdraw) |

### /api/v2/management/peatio/timestamp

#### POST
##### Description

Returns server time in seconds since Unix epoch.

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Returns server time in seconds since Unix epoch. |

### /api/v2/management/peatio/assets/new

#### POST
##### Description

Creates new asset operation.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency code. | Yes | string |
| code | formData | Operation account code | Yes | integer |
| debit | formData | Operation debit amount. | No | double |
| credit | formData | Operation credit amount. | No | double |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new asset operation. | [Operation](#operation) |

### /api/v2/management/peatio/assets

#### POST
##### Description

Returns assets as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency for operations filtering. | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of objects per page (defaults to 100, maximum is 1000). | No | integer |
| time_from | formData | An integer represents the seconds elapsed since Unix epoch.If set, only operations after the time will be returned. | No | integer |
| time_to | formData | An integer represents the seconds elapsed since Unix epoch.If set, only operations before the time will be returned. | No | integer |
| reference_type | formData | The reference type for operations filtering | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns assets as paginated collection. | [Operation](#operation) |

### /api/v2/management/peatio/expenses/new

#### POST
##### Description

Creates new expense operation.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency code. | Yes | string |
| code | formData | Operation account code | Yes | integer |
| debit | formData | Operation debit amount. | No | double |
| credit | formData | Operation credit amount. | No | double |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new expense operation. | [Operation](#operation) |

### /api/v2/management/peatio/expenses

#### POST
##### Description

Returns expenses as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency for operations filtering. | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of objects per page (defaults to 100, maximum is 1000). | No | integer |
| time_from | formData | An integer represents the seconds elapsed since Unix epoch.If set, only operations after the time will be returned. | No | integer |
| time_to | formData | An integer represents the seconds elapsed since Unix epoch.If set, only operations before the time will be returned. | No | integer |
| reference_type | formData | The reference type for operations filtering | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns expenses as paginated collection. | [Operation](#operation) |

### /api/v2/management/peatio/revenues/new

#### POST
##### Description

Creates new revenue operation.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency code. | Yes | string |
| code | formData | Operation account code | Yes | integer |
| debit | formData | Operation debit amount. | No | double |
| credit | formData | Operation credit amount. | No | double |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new revenue operation. | [Operation](#operation) |

### /api/v2/management/peatio/revenues

#### POST
##### Description

Returns revenues as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency for operations filtering. | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of objects per page (defaults to 100, maximum is 1000). | No | integer |
| time_from | formData | An integer represents the seconds elapsed since Unix epoch.If set, only operations after the time will be returned. | No | integer |
| time_to | formData | An integer represents the seconds elapsed since Unix epoch.If set, only operations before the time will be returned. | No | integer |
| reference_type | formData | The reference type for operations filtering | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns revenues as paginated collection. | [Operation](#operation) |

### /api/v2/management/peatio/liabilities/new

#### POST
##### Description

Creates new liability operation.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency code. | Yes | string |
| code | formData | Operation account code | Yes | integer |
| uid | formData | The user ID for operation owner. | Yes | string |
| debit | formData | Operation debit amount. | No | double |
| credit | formData | Operation credit amount. | No | double |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new liability operation. | [Operation](#operation) |

### /api/v2/management/peatio/liabilities

#### POST
##### Description

Returns liabilities as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | The currency for operations filtering. | No | string |
| uid | formData | The user ID for operations filtering. | No | string |
| reference_type | formData | The reference type for operations filtering | No | string |
| time_from | formData | An integer represents the seconds elapsed since Unix epoch.If set, only operations after the time will be returned. | No | integer |
| time_to | formData | An integer represents the seconds elapsed since Unix epoch.If set, only operations before the time will be returned. | No | integer |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of objects per page (defaults to 100, maximum is 10000). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns liabilities as paginated collection. | [Operation](#operation) |

### /api/v2/management/peatio/orders/cancel

#### POST
##### Description

Cancel all open orders

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | Filter order by owner uid | No | string |
| market | formData | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Cancel all open orders | [Order](#order) |

### /api/v2/management/peatio/orders/{id}/cancel

#### POST
##### Description

Cancel specific order

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | path | Unique order id. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Cancel specific order | [Order](#order) |

### /api/v2/management/peatio/orders

#### POST
##### Description

Returns orders

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | Filter order by owner uid | No | string |
| market | formData | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | No | string |
| state | formData | Filter order by state. | No | string |
| ord_type | formData | Filter order by ord_type. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns orders | [Order](#order) |

### /api/v2/management/peatio/transfers/new

#### POST
##### Description

Creates new transfer.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| key | formData | Unique Transfer Key. | Yes | string |
| category | formData | Transfer Category. | Yes | string |
| description | formData | Transfer Description. | No | string |
| operations[currency] | formData | Operation currency. | Yes | [ string ] |
| operations[amount] | formData | Operation amount. | Yes | [ double ] |
| operations[account_src][code] | formData | Source Account code. | Yes | [ integer ] |
| operations[account_src][uid] | formData | Source Account User ID (for accounts with member scope). | Yes | [ string ] |
| operations[account_dst][code] | formData | Destination Account code. | Yes | [ integer ] |
| operations[account_dst][uid] | formData | Destination Account User ID (for accounts with member scope). | Yes | [ string ] |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Creates new transfer. |

### /api/v2/management/peatio/trades

#### POST
##### Description

Returns trades as paginated collection.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | No | string |
| market | formData |  | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of objects per page (defaults to 100, maximum is 1000). | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns trades as paginated collection. | [Trade](#trade) |

### /api/v2/management/peatio/members/group

#### POST
##### Description

Set user group.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| group | formData | User gruop | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Set user group. |

### /api/v2/management/peatio/members

#### POST
##### Description

Create a member.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| email | formData | User email. | Yes | string |
| uid | formData | The shared user ID. | Yes | string |
| level | formData | User level. | Yes | integer |
| role | formData | User role. | Yes | string |
| state | formData | User state. | Yes | string |
| group | formData | User group | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Create a member. |

### /api/v2/management/peatio/fee_schedule/trading_fees

#### POST
##### Description

Returns trading_fees table as paginated collection

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| group | formData | Member group | No | string |
| market_id | formData | Market id | No | string |
| page | formData | The page number (defaults to 1). | No | integer |
| limit | formData | The number of objects per page (defaults to 100, maximum is 1000). | No | integer |

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Returns trading_fees table as paginated collection |

### /api/v2/management/peatio/currencies/update

#### PUT
##### Description

Update  currency.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Currency code. | Yes | string |
| name | formData | Currency name | No | string |
| deposit_fee | formData | Currency deposit fee | No | double |
| min_deposit_amount | formData | Minimal deposit amount | No | double |
| min_collection_amount | formData | Minimal deposit amount that will be collected | No | double |
| withdraw_fee | formData | Currency withdraw fee | No | double |
| min_withdraw_amount | formData | Minimal withdraw amount | No | double |
| withdraw_limit_24h | formData | Currency 24h withdraw limit | No | double |
| withdraw_limit_72h | formData | Currency 72h withdraw limit | No | double |
| position | formData | Currency position. | No | integer |
| options | formData | Currency options. | No | json |
| visible | formData | Currency display possibility status (true/false). | No | Boolean |
| deposit_enabled | formData | Currency deposit possibility status (true/false). | No | Boolean |
| withdrawal_enabled | formData | Currency withdrawal possibility status (true/false). | No | Boolean |
| precision | formData | Currency precision | No | integer |
| icon_url | formData | Currency icon | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update  currency. | [Currency](#currency) |

### /api/v2/management/peatio/currencies/{code}

#### POST
##### Description

Returns currency by code.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | path | The currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns currency by code. | [Currency](#currency) |

### /api/v2/management/peatio/currencies/list

#### POST
##### Description

Return currencies list.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| type | formData | Currency type | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Return currencies list. | [Currency](#currency) |

### /api/v2/management/peatio/markets/list

#### POST
##### Description

Return markets list.

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Return markets list. | [Market](#market) |

### /api/v2/management/peatio/markets/update

#### PUT
##### Description

Update market.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| id | formData | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | Yes | string |
| state | formData | Market state defines if user can see/trade on current market. | No | string |
| min_price | formData | Minimum order price. | No | double |
| min_amount | formData | Minimum order amount. | No | double |
| amount_precision | formData | Precision for order amount. | No | integer |
| price_precision | formData | Precision for order price. | No | integer |
| max_price | formData | Maximum order price. | No | double |
| position | formData | Market position. | No | integer |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update market. | [Market](#market) |

### Models

#### Beneficiary

Get list of user beneficiaries

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Beneficiary Identifier in Database | No |
| currency | string | Beneficiary currency code. | No |
| uid | string | Beneficiary owner | No |
| name | string | Human rememberable name which refer beneficiary. | No |
| description | string | Human rememberable description of beneficiary. | No |
| data | json | Bank Account details for fiat Beneficiary in JSON format.For crypto it's blockchain address. | No |
| state | string | Defines either beneficiary active - user can use it to withdraw moneyor pending - requires beneficiary activation with pin. | No |
| sent_at | string | Time when last pin was sent | No |

#### Balance

Queries the account balance for the given UID and currency.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| uid | string | The shared user ID. | No |
| balance | string | The account balance. | No |
| locked | string | The locked account balance. | No |

#### Deposit

Returns deposits as paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| tid | integer | The shared transaction ID. | No |
| currency | string | The currency code. | No |
| uid | string | The shared user ID. | No |
| type | string | The deposit type (fiat or coin). | No |
| amount | string | The deposit amount. | No |
| state | string | The deposit state. «submitted» – initial state. «canceled» – deposit has been canceled by outer service. «rejected» – deposit has been rejected by outer service.. «accepted» – deposit has been accepted by outer service, money are loaded. | No |
| created_at | string | The datetime when deposit was created. | No |
| completed_at | string | The datetime when deposit was completed. | No |
| blockchain_txid | string | The transaction ID on the Blockchain (coin only). | No |
| blockchain_confirmations | string | The number of transaction confirmations on the Blockchain (coin only). | No |
| transfer_type | string | deposit transfer_type. | No |

#### Withdraw

Returns withdraws as paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| tid | integer | The shared transaction ID. | No |
| uid | string | The shared user ID. | No |
| currency | string | The currency code. | No |
| note | string | The note for withdraw. | No |
| type | string | The withdraw type (fiat or coin). | No |
| amount | string | The withdraw amount excluding fee. | No |
| fee | string | The exchange fee. | No |
| rid | string | The beneficiary ID or wallet address on the Blockchain. | No |
| state | string | The withdraw state. «prepared» – initial state, money are not locked. «submitted» – withdraw has been allowed by outer service for further validation, money are locked. «canceled» – withdraw has been canceled by outer service, money are unlocked. «accepted» – system has validated withdraw and queued it for processing by worker, money are locked. «rejected» – system has validated withdraw and found errors, money are unlocked. «processing» – worker is processing withdraw as the current moment, money are locked. «skipped» – worker skipped withdrawal in case of insufficient balance of hot wallet or it absence. «succeed» – worker has successfully processed withdraw, money are subtracted from the account. «failed» – worker has encountered an unhandled error while processing withdraw, money are unlocked. | No |
| created_at | string | The datetime when withdraw was created. | No |
| blockchain_txid | string | The transaction ID on the Blockchain (coin only). | No |
| transfer_type | string | withdraw transfer_type. | No |

#### Operation

Returns liabilities as paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| code | string | The Account code which this operation related to. | No |
| currency | string | Operation currency ID. | No |
| credit | string | Operation credit amount. | No |
| debit | string | Operation debit amount. | No |
| uid | string | The shared user ID. | No |
| reference_type | string | The type of operations. | No |
| created_at | string | The datetime when operation was created. | No |

#### Order

Returns orders

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | integer | Unique order id. | No |
| member_id | integer | Member id. | No |
| uuid | string | Unique order UUID. | No |
| side | string | Either 'sell' or 'buy'. | No |
| ord_type | string | Type of order, either 'limit' or 'market'. | No |
| price | double | Price for each unit. e.g.If you want to sell/buy 1 btc at 3000 usd, the price is '3000.0' | No |
| avg_price | double | Average execution price, average of price in trades. | No |
| state | string | One of 'wait', 'done', or 'cancel'.An order in 'wait' is an active order, waiting fulfillment;a 'done' order is an order fulfilled;'cancel' means the order has been canceled. | No |
| market | string | The market in which the order is placed, e.g. 'btcusd'.All available markets can be found at /api/v2/markets. | No |
| created_at | string | Order create time in iso8601 format. | No |
| updated_at | string | Order updated time in iso8601 format. | No |
| origin_volume | double | The amount user want to sell/buy.An order could be partially executed,e.g. an order sell 5 btc can be matched with a buy 3 btc order,left 2 btc to be sold; in this case the order's volume would be '5.0',its remaining_volume would be '2.0', its executed volume is '3.0'. | No |
| remaining_volume | double | The remaining volume, see 'volume'. | No |
| executed_volume | double | The executed volume, see 'volume'. | No |
| maker_fee | double | Fee for maker. | No |
| taker_fee | double | Fee for taker. | No |
| trades_count | integer | Count of trades. | No |
| trades | [ [Trade](#trade) ] | Trades wiht this order. | No |

#### Trade

Returns trades as paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Trade ID. | No |
| price | double | Trade price. | No |
| amount | double | Trade amount. | No |
| total | double | Trade total (Amount * Price). | No |
| fee_currency | double | Currency user's fees were charged in. | No |
| fee | double | Percentage of fee user was charged for performed trade. | No |
| fee_amount | double | Amount of fee user was charged for performed trade. | No |
| market | string | Trade market id. | No |
| created_at | string | Trade create time in iso8601 format. | No |
| taker_type | string | Trade taker order type (sell or buy). | No |
| side | string | Trade side. | No |
| order_id | integer | Order id. | No |

#### Currency

Return currencies list.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Currency code.<br>_Example:_ `"btc"` | No |
| name | string | Currency name<br>_Example:_ `"Bitcoin"` | No |
| description | string | Currency description<br>_Example:_ `"btc"` | No |
| homepage | string | Currency homepage<br>_Example:_ `"btc"` | No |
| price | string | Currency current price | No |
| explorer_transaction | string | Currency transaction exprorer url template<br>_Example:_ `"https://testnet.blockchain.info/tx/"` | No |
| explorer_address | string | Currency address exprorer url template<br>_Example:_ `"https://testnet.blockchain.info/address/"` | No |
| type | string | Currency type<br>_Example:_ `"coin"` | No |
| deposit_enabled | string | Currency deposit possibility status (true/false). | No |
| withdrawal_enabled | string | Currency withdrawal possibility status (true/false). | No |
| deposit_fee | string | Currency deposit fee<br>_Example:_ `"0.0"` | No |
| min_deposit_amount | string | Minimal deposit amount<br>_Example:_ `"0.0000356"` | No |
| withdraw_fee | string | Currency withdraw fee<br>_Example:_ `"0.0"` | No |
| min_withdraw_amount | string | Minimal withdraw amount<br>_Example:_ `"0.0"` | No |
| withdraw_limit_24h | string | Currency 24h withdraw limit<br>_Example:_ `"0.1"` | No |
| withdraw_limit_72h | string | Currency 72h withdraw limit<br>_Example:_ `"0.2"` | No |
| base_factor | string | Currency base factor<br>_Example:_ `100000000` | No |
| precision | string | Currency precision<br>_Example:_ `8` | No |
| position | integer | Currency position. | No |
| icon_url | string | Currency icon<br>_Example:_ `"https://upload.wikimedia.org/wikipedia/commons/0/05/Ethereum_logo_2014.svg"` | No |
| min_confirmations | string | Number of confirmations required for confirming deposit or withdrawal | No |
| code | string | Unique currency code. | No |
| min_collection_amount | string | Minimal deposit amount that will be collected<br>_Example:_ `"0.0000356"` | No |
| visible | string | Currency display possibility status (true/false). | No |
| subunits | integer | Fraction of the basic monetary unit. | No |
| options | json | Currency options. | No |
| created_at | string | Currency created time in iso8601 format. | No |
| updated_at | string | Currency updated time in iso8601 format. | No |

#### Market

Update market.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Unique market id. It's always in the form of xxxyyy,where xxx is the base currency code, yyy is the quotecurrency code, e.g. 'btcusd'. All available markets canbe found at /api/v2/markets. | No |
| name | string | Market name. | No |
| base_unit | string | Market Base unit. | No |
| quote_unit | string | Market Quote unit. | No |
| min_price | double | Minimum order price. | No |
| max_price | double | Maximum order price. | No |
| min_amount | double | Minimum order amount. | No |
| amount_precision | double | Precision for order amount. | No |
| price_precision | double | Precision for order price. | No |
| state | string | Market state defines if user can see/trade on current market. | No |
| position | integer | Market position. | No |
| created_at | string | Market created time in iso8601 format. | No |
| updated_at | string | Market updated time in iso8601 format. | No |
