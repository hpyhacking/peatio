## How to import users and account balances in Peatio database

1. Create comma-separated `csv` files for users and accounts with the following structure.

### Users table

|      uid      | email          | level |    role      |  state  | referral_uid  |
|---------------|----------------|-------|--------------|---------|---------------|
| ID1000003837  | peatio@tech.io |   3   | superadmin   | active  | ID1000003828  |

uid, email - require params

### Accounts table

|      uid      | currency_id  | main_balance |  locked_balance  |
|---------------|--------------|--------------|------------------|
| ID1000003837  |     ETH      |      10      |        5         |

uid, currency_id - require params

2. Import users
   
```bash
   bundle exec rake import:users['file_name.csv']
```

3. Import accounts (users balances)

```bash
  bundle exec rake import:accounts['file_name.csv']
```
