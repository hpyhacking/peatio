module OWHDWallet
  class WalletETH < WalletAbstract
    include ::Ethereum::Eth::Params

    def default_fees
      { eth_gas_limit: 21_000, erc20_gas_limit: 90_000, gas_price: :standard }.freeze
    end

    def eth_like?
      true
    end

    def prepare_deposit_collection!(deposit_transaction, spread_transactions, deposit_currency)
      super
    end
  end
end
