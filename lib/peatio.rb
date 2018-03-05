module Peatio
  class << self
    def base_fiat_ccy
      Currency.base_fiat.yield_self do |ccy|
        raise ArgumentError, 'Base fiat currency is not specified.' unless ccy
        ccy.code
      end
    end

    def base_fiat_ccy_sym
      base_fiat_ccy.to_sym
    end
  end
end
