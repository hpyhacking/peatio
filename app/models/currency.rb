class Currency < ActiveYamlBase
  include ActiveHash::Associations

  field :visible, default: true

  self.singleton_class.send :alias_method, :all_with_invisible, :all

  class << self
    def all
      all_with_invisible.select &:visible
    end

    def enumerize
      all_with_invisible.each_with_object({}) { |i, memo| memo[i.code.to_sym] = i.id }
    end

    def codes
      @keys ||= all.map &:code
    end

    def ids
      @ids ||= all.map &:id
    end

    def assets(code)
      find_by_code(code)[:assets]
    end

    def coins
      @coins ||= Currency.where(coin: true)
    end

    def coin_codes
      @coin_codes ||= self.coins.map(&:code)
    end
  end

  def precision
    self[:precision]
  end

  def api
    raise unless coin?
    CoinAPI[code]
  end

  def fiat?
    not coin?
  end

  def balance_cache_key
    "peatio:hotwallet:#{code}:balance"
  end

  def balance
    Rails.cache.read(balance_cache_key) || 0
  end

  def decimal_digit
    self.try(:default_decimal_digit) || (fiat? ? 2 : 4)
  end

  def refresh_balance
    Rails.cache.write(balance_cache_key, api.load_balance || 'N/A') if coin?
  end

  def blockchain_url(txid)
    raise unless coin?
    blockchain.gsub('#{txid}', txid.to_s)
  end

  def address_url(address)
    raise unless coin?
    self[:address_url].try :gsub, '#{address}', address
  end

  def quick_withdraw_max
    @quick_withdraw_max ||= BigDecimal.new self[:quick_withdraw_max].to_s
  end

  # Allows to dynamically check value of code:
  #
  #   code.btc? # true if code equals to "btc".
  #   code.xrp? # true if code equals to "xrp".
  #
  def code
    self[:code]&.inquiry
  end

  def as_json(options = {})
    {
      key: key,
      code: code,
      coin: coin,
      blockchain: blockchain
    }
  end

  def summary
    locked = Account.locked_sum(code)
    balance = Account.balance_sum(code)
    sum = locked + balance

    coinable = self.coin?
    hot = coinable ? self.balance : nil

    {
      name: self.code.upcase,
      sum: sum,
      balance: balance,
      locked: locked,
      coinable: coinable,
      hot: hot
    }
  end

  def key_text
    code.upcase
  end

  def code_text
    code.upcase
  end

  def name_text
    code.upcase
  end
end
