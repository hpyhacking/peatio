# Peatio Airdrop API

This doc describes how you can process airdrops for users using Admin API

### Example for airdrop processing

1. Admin user make an deposit for the total amount of the airdrop on his deposit address for airdrop currency

Also you can do an adjustment for admin account but after airdrop make sure to deposit total amount of the airdrop to the platform hot wallet.

2. Prepare csv file for airdrop with the following format

|      uid      | currency_id | amount |
|---------------|-------------|--------|
| ID1000003838  | usdt        |  100   |
| ID1000003839  | usdt        |  100   |
| ID1000003840  | usdt        |  100   |

3. Load csv file from Tower in Promo -> Airdrops tab and click Submit button.

Also you can use directly Admin API with POST request to `api/v2/peatio/admin/airdrops`

Example with curl:

```bash
curl -X POST -F 'file=@spec/resources/airdrops/airdrop.csv' 'https://opendax.cloud/api/v2/admin/airdrops'
```

### Rules and exceptions

1. Admin who received deposit for the airdrop total amount should process airdrop from HIS user. Example:
    - Admin with uid ID1000001 received 300 usdt on his deposit account.
    - Admin with uid ID1000001 login and load csv in airdrop tab.
    - Airdrop API will take this user as src account and distribute funds from this account.

2. If user not exist in peatio DB it will be skipped.

3. If currency not exist in peatio DB airdrop will be skipped.

4. If admin doesn't have enough funds for whole airdrop system will not execute any transfers for provided csv.
