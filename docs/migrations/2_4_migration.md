Unlike Peatio v2.3, Peatio v2.4 stores wallets settings in Vault. Since all settings should be moved to Vault, we need to recreate wallets in Peatio. To do this, follow these steps:
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
2. Put content of the `config/seed/wallets_backup.yml` in the `config/seed/wallets.yml`.
3. Change the Peatio version.
4. Run `rake db:migrate db:seed`. It will migrate DB and seed wallets into Peatio.

