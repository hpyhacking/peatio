class Currency < Settingslogic
  def self.makeup(one, two)
    codes = self.codes
    codes[one.to_sym] ^ codes[two.to_sym]
  end

  def self.coin_urls
    @coins ||= self.coins.symbolize_keys
  end

  def self.codes
    # {:currency => :currency_code, ...}
    @codes ||= self.currencies.symbolize_keys
  end

  source "#{Rails.root}/config/currency.yml"
  namespace Rails.env
  suppress_errors Rails.env.production?
end
