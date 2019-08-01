## How to import users and account balances database Peatio

1. Create `csv` files for users and accounts with those templates.

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

2. For import users
   
```ruby
   bundle exec rake import:users['file_name.csv']
```

3. For import accounts

```ruby
  bundle exec rake import:accounts['file_name.csv']
```