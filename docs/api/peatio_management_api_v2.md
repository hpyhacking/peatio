# Peatio Management API v2
Management API is server-to-server API with high privileges.

## Version: 2.3.44

**Contact information:**  
openware.com  
https://www.openware.com  
hello@openware.com  

**License:** https://github.com/rubykube/peatio/blob/master/LICENSE.md

### /accounts/balance

#### POST
##### Description:

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

### /deposits/state

#### PUT
##### Description:

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

### /deposits/new

#### POST
##### Description:

Creates new fiat deposit with state set to «submitted». Optionally pass field «state» set to «accepted» if want to load money instantly. You can also use PUT /fiat_deposits/:id later to load money or cancel deposit.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| uid | formData | The shared user ID. | Yes | string |
| tid | formData | The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied. | No | string |
| currency | formData | The currency code. | Yes | string |
| amount | formData | The deposit amount. | Yes | double |
| state | formData | The state of deposit. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new fiat deposit with state set to «submitted». Optionally pass field «state» set to «accepted» if want to load money instantly. You can also use PUT /fiat_deposits/:id later to load money or cancel deposit. | [Deposit](#deposit) |

### /deposits/get

#### POST
##### Description:

Returns deposit by TID.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The transaction ID. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns deposit by TID. | [Deposit](#deposit) |

### /deposits

#### POST
##### Description:

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

### /withdraws/action

#### PUT
##### Summary:

Performs action on withdraw.

##### Description:

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

### /withdraws/new

#### POST
##### Summary:

Creates new withdraw.

##### Description:

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
| action | formData | The action to perform. | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Creates new withdraw. | [Withdraw](#withdraw) |

### /withdraws/get

#### POST
##### Description:

Returns withdraw by ID.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| tid | formData | The shared transaction ID. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns withdraw by ID. | [Withdraw](#withdraw) |

### /withdraws

#### POST
##### Description:

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

### /timestamp

#### POST
##### Description:

Returns server time in seconds since Unix epoch.

##### Responses

| Code | Description |
| ---- | ----------- |
| 201 | Returns server time in seconds since Unix epoch. |

### /assets/new

#### POST
##### Description:

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

### /assets

#### POST
##### Description:

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

### /expenses/new

#### POST
##### Description:

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

### /expenses

#### POST
##### Description:

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

### /revenues/new

#### POST
##### Description:

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

### /revenues

#### POST
##### Description:

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

### /liabilities/new

#### POST
##### Description:

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

### /liabilities

#### POST
##### Description:

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

### /transfers/new

#### POST
##### Description:

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

### /trades

#### POST
##### Description:

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

### /members/group

#### POST
##### Description:

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

### /fee_schedule/trading_fees

#### POST
##### Description:

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

### /currencies/update

#### PUT
##### Description:

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
| visible | formData | Currency display possibility status (true/false). | No | boolean |
| deposit_enabled | formData | Currency deposit possibility status (true/false). | No | boolean |
| withdrawal_enabled | formData | Currency withdrawal possibility status (true/false). | No | boolean |
| precision | formData | Currency precision | No | integer |
| icon_url | formData | Currency icon | No | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 200 | Update  currency. | [Currency](#currency) |

### /currencies/{code}

#### POST
##### Description:

Returns currency by code.

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| code | path | The currency code. | Yes | string |

##### Responses

| Code | Description | Schema |
| ---- | ----------- | ------ |
| 201 | Returns currency by code. | [Currency](#currency) |

### /markets/update

#### PUT
##### Description:

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

#### Withdraw

Returns withdraws as paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| tid | integer | The shared transaction ID. | No |
| uid | string | The shared user ID. | No |
| currency | string | The currency code. | No |
| type | string | The withdraw type (fiat or coin). | No |
| amount | string | The withdraw amount excluding fee. | No |
| fee | string | The exchange fee. | No |
| rid | string | The beneficiary ID or wallet address on the Blockchain. | No |
| state | string | The withdraw state. «prepared» – initial state, money are not locked. «submitted» – withdraw has been allowed by outer service for further validation, money are locked. «canceled» – withdraw has been canceled by outer service, money are unlocked. «accepted» – system has validated withdraw and queued it for processing by worker, money are locked. «rejected» – system has validated withdraw and found errors, money are unlocked. «processing» – worker is processing withdraw as the current moment, money are locked. «skipped» – worker skipped withdrawal in case of insufficient balance of hot wallet or it absence. «succeed» – worker has successfully processed withdraw, money are subtracted from the account. «failed» – worker has encountered an unhandled error while processing withdraw, money are unlocked. | No |
| created_at | string | The datetime when withdraw was created. | No |
| blockchain_txid | string | The transaction ID on the Blockchain (coin only). | No |

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

#### Trade

Returns trades as paginated collection.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Trade ID. | No |
| price | double | Trade price. | No |
| amount | double | Trade amount. | No |
| total | double | Trade total. | No |
| market | string | Trade market id. | No |
| created_at | string | Trade create time in iso8601 format. | No |
| maker_order_id | string | Trade maker order id. | No |
| taker_order_id | string | Trade taker order id. | No |
| maker_member_uid | string | Trade ask member uid. | No |
| taker_member_uid | string | Trade bid member uid. | No |
| taker_type | string | Trade maker order type (sell or buy). | No |
| side | string | Trade side. | No |
| order_id | integer | Order id. | No |

#### Currency

Returns currency by code.

| Name | Type | Description | Required |
| ---- | ---- | ----------- | -------- |
| id | string | Currency code. | No |
| name | string | Currency name | No |
| symbol | string | Currency symbol | No |
| explorer_transaction | string | Currency transaction exprorer url template | No |
| explorer_address | string | Currency address exprorer url template | No |
| type | string | Currency type | No |
| deposit_enabled | string | Currency deposit possibility status (true/false). | No |
| withdrawal_enabled | string | Currency withdrawal possibility status (true/false). | No |
| deposit_fee | string | Currency deposit fee | No |
| min_deposit_amount | string | Minimal deposit amount | No |
| withdraw_fee | string | Currency withdraw fee | No |
| min_withdraw_amount | string | Minimal withdraw amount | No |
| withdraw_limit_24h | string | Currency 24h withdraw limit | No |
| withdraw_limit_72h | string | Currency 72h withdraw limit | No |
| base_factor | string | Currency base factor | No |
| precision | string | Currency precision | No |
| icon_url | string | Currency icon | No |
| min_confirmations | string | Number of confirmations required for confirming deposit or withdrawal | No |
| code | string | Unique currency code. | No |
| min_collection_amount | string | Minimal deposit amount that will be collected | No |
| visible | string | Currency display possibility status (true/false). | No |
| subunits | integer | Fraction of the basic monetary unit. | No |
| options | json | Currency options. | No |
| position | integer | Currency position. | No |
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