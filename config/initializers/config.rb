# frozen_string_literal: true

require 'peatio/app'

Peatio::App.define do |config|
  config.set(:deposit_funds_locked, 'false', type: :bool)
  config.set(:platform_currency, 'usdt')
  config.set(:price_fetch_period_time, '300', type: :integer) # in seconds
end
