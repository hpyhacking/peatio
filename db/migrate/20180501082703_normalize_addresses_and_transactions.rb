# encoding: UTF-8
# frozen_string_literal: true

class NormalizeAddressesAndTransactions < ActiveRecord::Migration
  class Ccy < ActiveRecord::Base
    serialize :options, JSON
    self.table_name = 'currencies'
    self.inheritance_column = :disabled
  end

  def change
    Ccy.where(type: :coin).find_each do |ccy|
      if ccy.code.in?(%w[eth ethd])
        ccy.options['bitgo_wallet_address'].try(:downcase!)
        ccy.options['erc20_contract_address'].try(:downcase!)
        ccy.save
        execute %[UPDATE deposits SET address = LOWER(address), txid = LOWER(txid) WHERE currency_id = #{ccy.id}]
        execute %[UPDATE payment_addresses SET address = LOWER(address) WHERE currency_id = #{ccy.id}]
        execute %[UPDATE withdraws SET rid = LOWER(rid), txid = LOWER(txid) WHERE type = 'Withdraws::Coin' AND currency_id = #{ccy.id}]
      else
        ccy.options['case_sensitive'] = true
        ccy.save
      end
    end
  end
end
