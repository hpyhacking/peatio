module OWHDWallet
  class WalletHECO < WalletAbstract
    include ::Ethereum::Heco::Params

    def default_fees
      { heco_gas_limit: 21_000, hrc20_gas_limit: 90_000, gas_price: :standard }.freeze
    end

    def eth_like?
      true
    end

    def wallet_gateway_url
      @wallet[:gateway_url] || default_wallet_gateway_url
    end

    def default_wallet_gateway_url
      if testnet?
        'https://http-testnet.hecochain.com'
      else
        'https://http-mainnet.hecochain.com'
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
