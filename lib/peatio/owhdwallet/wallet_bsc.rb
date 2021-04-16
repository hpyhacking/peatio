module OWHDWallet
  class WalletBSC < WalletAbstract
    include ::Ethereum::Bsc::Params

    def default_fees
      { bsc_gas_limit: 21_000, bep20_gas_limit: 90_000, gas_price: :standard }.freeze
    end

    def eth_like?
      true
    end

    def wallet_gateway_url
      @wallet[:gateway_url] || default_wallet_gateway_url
    end

    def default_wallet_gateway_url
      if testnet?
        'https://data-seed-prebsc-1-s1.binance.org:8545/'
      else
        'https://bsc-dataseed.binance.org/'
      end
    end

    def testnet?
      @wallet[:testnet]
    end

    def prepare_deposit_collection!(deposit_transaction, spread_transactions, deposit_currency)
      super
    end
  end
end
