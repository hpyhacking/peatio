# frozen_string_literal: true

require 'peatio/app'

Peatio::App.define do |config|
  config.set(:deposit_funds_locked, 'false', type: :bool)
  config.set(:platform_currency, 'usdt')
  config.set(:currency_price_fetch_period_time, '300', type: :integer) # in seconds
  config.set(:adjust_network_fee_fetch_period_time, '300', type: :integer) # in seconds
  config.set(:manual_deposit_approval, 'false', type: :bool)
  config.set(:default_account_type, 'spot')
  config.set(:account_types, '')
  config.set(:force_beneficiaries_whitelisting, 'true', type: :bool)
end
