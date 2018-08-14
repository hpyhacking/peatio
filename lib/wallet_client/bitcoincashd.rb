# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Bitcoincashd < Bitcoind

    def normalize_address(address)
      CashAddr::Converter.to_legacy_address(super)
    end

  end
end
