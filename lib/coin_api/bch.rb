# encoding: UTF-8
# frozen_string_literal: true

module CoinAPI
  class BCH < BTC
    def normalize_address(address)
      CashAddr::Converter.to_legacy_address(super)
    end
  end
end
