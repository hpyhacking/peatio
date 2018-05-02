class Currency < ActiveRecord::Base
  serialize :options, JSON

  attr_readonly :code, :type, :case_sensitive, :erc20_contract_address

  # NOTE: type column reserved for STI
  self.inheritance_column = nil

  validates :type, inclusion: { in: -> (_) { Currency.types.map(&:to_s) } }
  validates :code, presence: true, uniqueness: true
  validates :symbol, presence: true, length: { maximum: 1 }
  validates :json_rpc_endpoint, :rest_api_endpoint, length: { maximum: 200 }, url: { allow_blank: true }
  validates :options, length: { maximum: 1000 }
  validates :wallet_url_template, :transaction_url_template, length: { maximum: 200 }, url: { allow_blank: true }
  validates :quick_withdraw_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :base_factor, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :deposit_confirmations, numericality: { greater_than_or_equal_to: 0, only_integer: true }, if: :coin?
  validates :withdraw_fee, :deposit_fee, numericality: { greater_than_or_equal_to: 0 }
  validate { errors.add(:options, :invalid) unless Hash === options }

  before_validation { self.deposit_fee = 0 unless fiat? }

  before_validation do
    next unless code&.bch? && bitgo_wallet_address?
    self.bitgo_wallet_address = CashAddr::Converter.to_legacy_address(bitgo_wallet_address)
  end

  before_validation do
    next if case_sensitive?
    self.bitgo_wallet_address   = bitgo_wallet_address.try(:downcase)
    self.erc20_contract_address = erc20_contract_address.try(:downcase)
  end

  scope :visible, -> { where(visible: true) }
  scope :all_with_invisible, -> { all }

  scope :coins, -> { where(type: :coin) }
  scope :fiats, -> { where(type: :fiat) }

  class << self
    def codes(options = {})
      visible.pluck(:code).yield_self do |downcase_codes|
        case
          when options.fetch(:bothcase, false)
            downcase_codes + downcase_codes.map(&:upcase)
          when options.fetch(:upcase, false)
            downcase_codes.map(&:upcase)
          else
            downcase_codes
        end
      end
    end

    def coin_codes(options = {})
      coins.codes(options)
    end

    def fiat_codes(options = {})
      fiats.codes(options)
    end

    def types
      %i[fiat coin].freeze
    end
  end

  def api
    raise unless coin?
    CoinAPI[code]
  end

  def balance_cache_key
    "peatio:hotwallet:#{code}:balance"
  end

  def balance
    Rails.cache.read(balance_cache_key) || 0
  end

  def refresh_balance
    Rails.cache.write(balance_cache_key, api.load_balance || 'N/A') if coin?
  end

  # Allows to dynamically check value of code:
  #
  #   code.btc? # true if code equals to "btc".
  #   code.xrp? # true if code equals to "xrp".
  #
  def code
    super&.inquiry
  end

  def code=(code)
    super(code.to_s.downcase)
  end

  types.each { |t| define_method("#{t}?") { type == t.to_s } }

  def as_json(*)
    { code:                     code,
      coin:                     coin?,
      fiat:                     fiat?,
      transaction_url_template: transaction_url_template }
  end

  def summary
    locked = Account.locked_sum(code)
    balance = Account.balance_sum(code)
    sum = locked + balance

    coinable = coin?
    hot = coinable ? balance : nil

    {
      name: code.upcase,
      sum: sum,
      balance: balance,
      locked: locked,
      coinable: coinable,
      hot: hot
    }
  end

  class << self
    def nested_attr(*names)
      names.each do |name|
        name_string = name.to_s
        define_method(name)              { options[name_string] }
        define_method(name_string + '?') { options[name_string].present? }
        define_method(name_string + '=') { |value| options[name_string] = value }
        define_method(name_string + '!') { options.fetch!(name_string) }
      end
    end
  end

  nested_attr \
    :api_client,
    :json_rpc_endpoint,
    :rest_api_endpoint,
    :deposit_confirmations,
    :bitgo_test_net,
    :bitgo_wallet_id,
    :bitgo_wallet_address,
    :bitgo_wallet_passphrase,
    :bitgo_rest_api_root,
    :bitgo_rest_api_access_token,
    :wallet_url_template,
    :transaction_url_template,
    :erc20_contract_address,
    :case_sensitive

  def deposit_confirmations
    options['deposit_confirmations'].to_i
  end

  def deposit_confirmations=(n)
    options['deposit_confirmations'] = n.to_i
  end

  def case_sensitive?
    !!case_sensitive
  end

  def case_insensitive?
    !case_sensitive?
  end
end

# == Schema Information
# Schema version: 20180425224307
#
# Table name: currencies
#
#  id                   :integer          not null, primary key
#  code                 :string(30)       not null
#  symbol               :string(1)        not null
#  type                 :string(30)       default("coin"), not null
#  deposit_fee          :decimal(32, 16)  default(0.0), not null
#  quick_withdraw_limit :decimal(32, 16)  default(0.0), not null
#  withdraw_fee         :decimal(32, 16)  default(0.0), not null
#  options              :string(1000)     default({}), not null
#  visible              :boolean          default(TRUE), not null
#  base_factor          :integer          default(1), not null
#  precision            :integer          default(8), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_currencies_on_code     (code) UNIQUE
#  index_currencies_on_visible  (visible)
#
