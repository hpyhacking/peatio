### Starting from Peatio from 2.3.48 wallets settings stores in Vault. Since all settings should be moved to Vault, we need to recreate wallets in Peatio.
To do this, follow these steps:

1. Execute into Rails Console and run:

```ruby
  result = Wallet.all.map { |m| m.attributes.except('created_at', 'updated_at') }.map { |r| r.transform_values! { |v| v.is_a?(BigDecimal) ? v.to_f : v } }
  result.each do |w|
    w.except!('settings_encrypted', 'id')
    w['settings'] = Wallet.find_by(address: w['address']).settings
    w['kind'] = w['kind'].to_s
  end

  File.open("config/seed/wallets_backup.yml","w") do |file|
     file.write result.to_yaml
  end

  Wallet.delete_all
```

1. Put content of the `config/seed/wallets_backup.yml` in the `config/seed/wallets.yml`.
2. Change the Peatio version.
3. Run `rake db:migrate db:seed`. It will migrate DB and seed wallets into Peatio.

### If you are using Peatio 2.3.62 or higher and you need to move to another Vault instance you will need to export wallets settings and user payment_addresses and import it to the new environment.
To do this you will need to process this steps:

1. Export wallet settings:

```ruby
  bundle exec rake export:wallets
```

2. Export user addresses:

```ruby
  bundle exec rake export:addresses
```

3. Put content of the `config/seed/wallets_backup.yml` in the `config/seed/wallets.yml`.
4. Change the Peatio version.
5. Run `rake db:migrate db:seed`. It will migrate DB and seed wallets into Peatio.
6. Import user addresses:

```ruby
  bundle exec rake import:addresses['file_name.csv']
```
