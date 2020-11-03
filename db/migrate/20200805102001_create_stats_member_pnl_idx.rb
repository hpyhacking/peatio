# frozen_string_literal: true

class CreateStatsMemberPnlIdx < ActiveRecord::Migration[5.2]
  def change
    create_table :stats_member_pnl_idx do |t|
      t.string :pnl_currency_id, limit: 10, null: false
      t.string :currency_id, limit: 10, null: false
      t.string :reference_type, limit: 255, null: false
      t.bigint :last_id
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      case ActiveRecord::Base.connection.adapter_name
      when 'Mysql2'
        t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP' }

      when 'PostgreSQL'
        t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      else
        raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
      end


      t.index %i[pnl_currency_id currency_id last_id], name: 'index_currency_ids_and_last_id'
      t.index %i[pnl_currency_id currency_id reference_type], unique: true, name: 'index_currency_ids_and_type'
    end
  end
end
