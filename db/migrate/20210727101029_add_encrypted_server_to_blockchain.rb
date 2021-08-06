class AddEncryptedServerToBlockchain < ActiveRecord::Migration[5.2]
  def up
    unless column_exists?(:blockchains, :server_encrypted)
      server = Blockchain.pluck(:id, :server)

      add_column :blockchains, :server_encrypted, :string, limit: 1024, after: :client

      server.each do |s|
        atr = Blockchain.__vault_attributes[:server]
        enc = Vault::Rails.encrypt(atr[:path], atr[:key], s[1])
        query = ActiveRecord::Base.sanitize_sql_array(["UPDATE blockchains SET server_encrypted = ? WHERE id = ?", enc, s[0]])
        execute(query)
      end
      remove_column :blockchains, :server
    end
  end

  def down
    if column_exists?(:blockchains, :server_encrypted)
      server = Blockchain.pluck(:id, :server_encrypted)

      add_column :blockchains, :server, :string, limit: 1000, default: '', null: false, after: :client

      server.each do |s|
        atr = Blockchain.__vault_attributes[:server]
        dec = Vault::Rails.decrypt(atr[:path], atr[:key], s[1])
        query = ActiveRecord::Base.sanitize_sql_array(["UPDATE blockchains SET server = ? WHERE id = ?", dec, s[0]])
        execute(query)
      end
      remove_column :blockchains, :server_encrypted , :string, limit: 1024, after: :client
    end
  end
end
