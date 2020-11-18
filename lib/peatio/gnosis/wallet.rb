module Gnosis
  class Wallet < Ethereum::Wallet
    def create_address!(_options = {})
      method_not_implemented
    end

    def create_transaction!(_transaction, _options = {})
      method_not_implemented
    end

    def prepare_deposit_collection!(_transaction, _deposit_spread, _deposit_currency)
      method_not_implemented
    end
  end
end
