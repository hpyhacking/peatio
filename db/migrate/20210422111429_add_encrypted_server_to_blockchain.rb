class AddEncryptedServerToBlockchain < ActiveRecord::Migration[5.2]
  def up
    server = Blockchain.pluck(:id, :server)

    remove_column :blockchains, :server
    add_column :blockchains, :server_encrypted , :string, limit: 1024, after: :client

    server.each do |s|
      atr = Blockchain.__vault_attributes[:server]
      enc = Vault::Rails.encrypt(atr[:path], atr[:key], s[1])
      query = ActiveRecord::Base.sanitize_sql_array(["UPDATE blockchains SET ? = ? WHERE id = ?", atr[:encrypted_column], enc, s[0]])
      execute(query)
    end
  end

  def downcase
    server = Blockchain.pluck(:id, :server_encrypted)

    add_column :blockchains, :server, :string, limit: 1000, default: '', null: false, after: :client
    remove_column :blockchains, :server_encrypted , :string, limit: 1024, after: :client

    server.each do |s|
      atr = Blockchain.__vault_attributes[:server]
      dec = Vault::Rails.decrypt(atr[:path], atr[:key], s[1])
      query = ActiveRecord::Base.sanitize_sql_array(["UPDATE blockchains SET server = ? WHERE id = ?", dec, s[0]])
      execute(query)
    end
  end
end
