class AddEncryptedSecretToPaymentAddress < ActiveRecord::Migration[5.2]
  def up
    secrets = PaymentAddress.pluck(:id, :secret)
    details = PaymentAddress.pluck(:id, :details)
    settings = Wallet.pluck(:id, :settings)

    remove_column :payment_addresses, :secret
    add_column :payment_addresses, :secret_encrypted , :string, limit: 255, after: :address

    remove_column :payment_addresses, :details
    add_column :payment_addresses, :details_encrypted , :string, limit: 1024, after: :secret_encrypted

    remove_column :wallets, :settings
    add_column :wallets, :settings_encrypted , :string, limit: 1024, after: :gateway

    secrets.each do |s|
      atr = PaymentAddress.__vault_attributes[:secret]
      enc = Vault::Rails.encrypt(atr[:path], atr[:key], s[1])
      execute "UPDATE payment_addresses SET #{atr[:encrypted_column]} = '#{enc}' WHERE id = #{s[0]}"
    end

    details.each do |d|
      atr = PaymentAddress.__vault_attributes[:details]
      enc = Vault::Rails.encrypt(atr[:path], atr[:key], d[1])
      execute "UPDATE payment_addresses SET #{atr[:encrypted_column]} = '#{enc}' WHERE id = #{d[0]}"
    end

    settings.each do |s|
      atr = Wallet.__vault_attributes[:settings]
      enc = Vault::Rails.encrypt(atr[:path], atr[:key], s[1])
      execute "UPDATE wallets SET #{atr[:encrypted_column]} = '#{enc}' WHERE id = #{s[0]}"
    end
  end

  def down
    secrets = PaymentAddress.pluck(:id, :secret_encrypted)
    details = PaymentAddress.pluck(:id, :details_encrypted)
    settings = Wallet.pluck(:id, :settings_encrypted)

    add_column :payment_addresses, :secret, :string, limit: 128, after: :address
    remove_column :payment_addresses, :secret_encrypted , :string, after: :address

    add_column :payment_addresses, :details, :string, limit: 1.kilobyte, null: false, default: '{}', after: :secret
    remove_column :payment_addresses, :details_encrypted , :string, limit: 1024, after: :secret_encrypted

    add_column :wallets, :settings, :string, limit: 1000, default: '{}', null: false, after: :gateway
    remove_column :wallets, :settings_encrypted , :string, limit: 1024, after: :gateway

    secrets.each do |s|
      atr = PaymentAddress.__vault_attributes[:secret]
      dec = Vault::Rails.decrypt(atr[:path], atr[:key], s[1])
      execute "UPDATE payment_addresses SET secret = '#{dec}' WHERE id = #{s[0]}"
    end

    details.each do |d|
      atr = PaymentAddress.__vault_attributes[:details]
      dec = Vault::Rails.decrypt(atr[:path], atr[:key], d[1])
      execute "UPDATE payment_addresses SET details = '#{dec}' WHERE id = #{d[0]}"
    end

    settings.each do |s|
      atr = Wallet.__vault_attributes[:settings]
      dec = Vault::Rails.decrypt(atr[:path], atr[:key], s[1])
      execute "UPDATE wallets SET settings = '#{dec}' WHERE id = #{s[0]}"
    end
  end
end
