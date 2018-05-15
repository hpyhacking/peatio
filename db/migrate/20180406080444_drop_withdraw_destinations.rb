# encoding: UTF-8
# frozen_string_literal: true

class DropWithdrawDestinations < ActiveRecord::Migration
  class WithdrawDestination < ActiveRecord::Base
    serialize :details, JSON
    self.inheritance_column = :disabled
  end

  def change
    execute('SELECT id, type, destination_id FROM withdraws').each do |fields|
      record = WithdrawDestination.where(type: fields[1].gsub(/Withdraws::/, 'WithdrawDestination::'))
                                  .find_by_id(fields[2])
      rid = if record
        fields[1].match?(/fiat/) ? record.details['bank_account_number'] : record.details['address']
      end.presence || fields[0]
      execute "UPDATE withdraws SET rid = #{connection.quote(rid)} WHERE id = #{connection.quote(fields[0])}"
    end

    remove_column :withdraws, :destination_id
    drop_table :withdraw_destinations
    change_column :withdraws, :rid, :string, limit: 64, null: false
    remove_column :accounts, :default_withdraw_destination_id
  end
end
