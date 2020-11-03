# encoding: UTF-8
# frozen_string_literal: true

class CaseSensitiveData < ActiveRecord::Migration[4.2]
  def change
    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      execute %[ALTER TABLE deposits MODIFY address VARCHAR(64) BINARY;]
      execute %[ALTER TABLE deposits MODIFY txid VARCHAR(128) BINARY;]
      execute %[ALTER TABLE deposits MODIFY tid VARCHAR(64) BINARY NOT NULL;]
      execute %[ALTER TABLE withdraws MODIFY txid VARCHAR(128) BINARY;]
      execute %[ALTER TABLE payment_addresses MODIFY address VARCHAR(64) BINARY;]
      execute %[ALTER TABLE withdraws MODIFY tid VARCHAR(64) BINARY NOT NULL;]
      execute %[ALTER TABLE withdraws MODIFY rid VARCHAR(64) BINARY NOT NULL;]

    when 'PostgreSQL'
      enable_extension 'citext'
      change_column :deposits, :address, :citext
      change_column :deposits, :txid, :citext
      change_column :deposits, :tid, :citext, null: false
      change_column :withdraws, :txid, :citext
      change_column :payment_addresses, :address, :citext
      change_column :withdraws, :tid, :citext, null: false
      change_column :withdraws, :rid, :citext, null: false
    else
      raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
    end
  end
end
