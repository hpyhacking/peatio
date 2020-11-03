class AddWalletBalance < ActiveRecord::Migration[5.2]
  def change
    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      add_column :wallets, :balance, :json, after: :settings_encrypted
    when 'PostgreSQL'
      add_column :wallets, :balance, :jsonb
    else
      raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
    end
  end
end
