class AddEncryptedDataToBeneficiary < ActiveRecord::Migration[5.2]
  def up
    data = Beneficiary.pluck(:id, :data)
    add_column :beneficiaries, :data_encrypted, :string, limit: 1024, after: :description
    data.each do |s|
      atr = Beneficiary.__vault_attributes[:data]
      enc = Vault::Rails.encrypt(atr[:path], atr[:key], s[1])
      query = ActiveRecord::Base.sanitize_sql_array(['UPDATE beneficiaries SET data_encrypted = ? WHERE id = ?', enc, s[0]])
      execute(query)
    end
    remove_column :beneficiaries, :data
  end

  def down
    data = Beneficiary.pluck(:id, :data_encrypted)
    add_column :beneficiaries, :data, :json, after: :description
    data.each do |s|
      atr = Beneficiary.__vault_attributes[:data]
      dec = Vault::Rails.decrypt(atr[:path], atr[:key], s[1])
      query = ActiveRecord::Base.sanitize_sql_array(['UPDATE beneficiaries SET data = ? WHERE id = ?', dec, s[0]])
      execute(query)
    end
    remove_column :beneficiaries, :data_encrypted
  end
end
