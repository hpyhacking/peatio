# frozen_string_literal: true

class ReplaceIdToCode < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.transaction do
      change_column :currencies, :code, :string, limit: 10, null: false
      change_column :currencies, :id, :string, limit: 10, null: false

      change_column :deposits, :currency_id, :string, limit: 10
      change_column :withdraws, :currency_id, :string, limit: 10
      change_column :payment_addresses, :currency_id, :string, limit: 10
      change_column :accounts, :currency_id, :string, limit: 10
      change_column :proofs, :currency_id, :string, limit: 10
      change_column :orders, :ask, :string, limit: 10
      change_column :orders, :bid, :string, limit: 10

      Currency.all.each do |c|
        Deposits.where(currency_id: c.id).update_all(currency_id: c.code)
        Withdraws.where(currency_id: c.id).update_all(currency_id: c.code)
        PaymentAddresses.where(currency_id: c.id).update_all(currency_id: c.code)
        Accounts.where(currency_id: c.id).update_all(currency_id: c.code)
        Proofs.where(currency_id: c.id).update_all(currency_id: c.code)

        %i[deposits withdraws payment_addresses accounts proofs].each do |t|
          change_column t, :currency_id, :string, limit: 10
        end

        Orders.where(ask: c.id).update_all(ask: c.code)
        Orders.where(bid: c.id).update_all(bid: c.code)
      end

      Currency.update_all('id = code')
      remove_column :currencies, :code

      if index_exists?(:currencies, %i[enabled code])
        remove_index :currencies, column: %i[enabled code]
      end

      add_index :currencies, [:enabled]
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration can't be rollbacked"
  end
end
