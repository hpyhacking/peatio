# frozen_string_literal: true

class MakeUUIDNotNil < ActiveRecord::Migration[5.2]
  def change
    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      execute('UPDATE orders SET uuid = (UNHEX(REPLACE(UUID(), "-",""))) WHERE uuid IS NULL')
      change_column :orders, :uuid, :binary, limit: 16, index: { unique: true }, after: :id, null: false

    when 'PostgreSQL'
      enable_extension 'uuid-ossp'
      enable_extension 'pgcrypto'

      remove_column :orders, :uuid
      add_column :orders, :uuid, :uuid, index: { unique: true }, after: :id, null: false, default: 'gen_random_uuid()'

    else
      raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
    end
  end
end
