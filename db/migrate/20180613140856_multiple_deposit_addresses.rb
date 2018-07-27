# encoding: UTF-8
# frozen_string_literal: true

class MultipleDepositAddresses < ActiveRecord::Migration
  class Currency < ActiveRecord::Base
    serialize :options, JSON
    self.inheritance_column = nil
  end

  def change
    Currency.transaction do
      Currency.where(type: :coin).find_each do |ccy|
        unless ccy.options.key?('supports_hd_protocol')
          ccy.options['supports_hd_protocol'] = \
            ccy.id.in?(%w[btc btcd bch bchd ltc ltcd dash dashd]) ||
            (ccy.id.in?(%w[xrp eth]) && ccy.options['api_client'] == 'BitGo')
        end

        unless ccy.options.key?('allow_multiple_deposit_addresses')
          ccy.options['allow_multiple_deposit_addresses'] = false
        end

        ccy.save!
      end
    end
  end
end
