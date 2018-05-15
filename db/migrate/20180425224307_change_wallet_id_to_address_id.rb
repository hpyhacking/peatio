# encoding: UTF-8
# frozen_string_literal: true

class ChangeWalletIdToAddressId < ActiveRecord::Migration
  def change
    return unless defined?(PaymentAddress)
    return unless column_exists?(:payment_addresses, :details)
    PaymentAddress.find_each do |pa|
      pa.details['wallet_id'].tap do |wallet_id|
        if wallet_id
          pa.details['bitgo_address_id'] = wallet_id
          pa.details.delete('wallet_id')
          pa.update_column(:details, pa.details)
        end
      end
    end
  end
end
