# frozen_string_literal: true

class CreateStatsMemberPnl < ActiveRecord::Migration[5.2]
  def change
    create_table :stats_member_pnl do |t|
      t.integer :member_id, null: false
      t.string :pnl_currency_id, limit: 10, null: false
      t.string :currency_id,           limit: 10, null: false
      t.decimal :total_credit,         precision: 48, scale: 16, default: 0
      t.decimal :total_credit_fees,    precision: 48, scale: 16, default: 0
      t.decimal :total_debit_fees,     precision: 48, scale: 16, default: 0
      t.decimal :total_debit,          precision: 48, scale: 16, default: 0
      t.decimal :total_credit_value,   precision: 48, scale: 16, default: 0
      t.decimal :total_debit_value,    precision: 48, scale: 16, default: 0
      t.decimal :total_balance_value,  precision: 48, scale: 16, default: 0
      t.decimal :average_balance_price,precision: 48, scale: 16, default: 0
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      case ActiveRecord::Base.connection.adapter_name
      when 'Mysql2'
        t.datetime :updated_at, null: false, default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }

      when 'PostgreSQL'
        t.datetime :updated_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      else
        raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
      end

      t.index %i[pnl_currency_id currency_id member_id], unique: true, :name => 'index_currency_ids_and_member_id'
    end
  end
end
