# encoding: UTF-8
# frozen_string_literal: true

class CreateWithdrawDestinationsDropFundSource < ActiveRecord::Migration
  def change
    create_table :withdraw_destinations do |t|
      t.string  :type,        null: false, limit: 30, index: true
      t.integer :member_id,   null: false, index: true
      t.integer :currency_id, null: false, index: true
      t.string  :details,     limit: 4.kilobytes, null: false, default: '{}'
      t.timestamps            null: false
    end

    add_column :withdraws, :destination_id, :integer, after: :id, null: true, index: true

    migrate_existing_data

    remove_column :withdraws, :fund_uid
    remove_column :withdraws, :fund_extra

    rename_column :accounts, :default_withdraw_fund_source_id, :default_withdraw_destination_id
    drop_table :fund_sources
  end

private

  def migrate_existing_data
    return unless defined?(Withdraw) && defined?(WithdrawDestination)
    Withdraw.transaction do
      Withdraw.find_each do |withdraw|
        if Withdraws::Fiat === withdraw
          WithdrawDestination::Fiat.create! \
            label:               withdraw.fund_extra,
            member:              withdraw.member,
            currency:            withdraw.currency,
            bank_name:           withdraw.fund_extra,
            bank_account_number: withdraw.fund_uid
        else
          WithdrawDestination::Coin.create! \
            label:    withdraw.fund_extra,
            member:   withdraw.member,
            currency: withdraw.currency,
            address:  withdraw.fund_uid
        end.tap { |record| withdraw.update!(destination: record) }
      end
    end
  end
end
