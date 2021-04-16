module Ethereum::Heco
  class Wallet < ::Ethereum::WalletAbstract
    include Params

    def prepare_deposit_collection!(deposit_transaction, spread_transactions, deposit_currency)
      super
    end
  end
end
