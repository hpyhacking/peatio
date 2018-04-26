module CoinAPI
  class BCH < BTC
  protected

    def normalize_address(address)
      CashAddr::Converter.to_legacy_address(address)
    end
  end
end
