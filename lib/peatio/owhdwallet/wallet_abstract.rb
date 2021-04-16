module OWHDWallet
  class WalletAbstract < Peatio::Wallet::Abstract
    DEFAULT_FEATURES = { skip_deposit_collection: false }.freeze
    GAS_SPEEDS = %w[standard safelow fast].freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      # Clean client state during configure.
      @client = nil

      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))

      @wallet = @settings.fetch(:wallet) do
        raise Peatio::Wallet::MissingSettingError, :wallet
      end.slice(:uri, :gateway_url, :address, :secret, :wallet_index, :gas_price)

      @currency = @settings.fetch(:currency) do
        raise Peatio::Wallet::MissingSettingError, :currency
      end.slice(:id, :base_factor, :options)
    end

    def create_address!(_options = {})
      response = client.rest_api(:post, '/wallet/new', coin_type: coin_type)

      {
        address: response['address'],
        secret: response['passphrase'],
        details: response.except('address', 'passphrase')
      }
    rescue OWHDWallet::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def create_transaction!(transaction, options = {})
      params = eth_like? ? eth_transaction_params(transaction, options) : {}

      amount = convert_to_base_unit(transaction.amount)
      response = client.rest_api(:post, '/tx/send', {
        coin_type: coin_type,
        to: transaction.to_address,
        amount: amount.to_i,
        gateway_url: wallet_gateway_url,
        wallet_index: wallet_index,
        passphrase: wallet_secret
      }.merge(params))

      transaction.hash = response['tx']
      transaction.options = response['options'] if response['options'].present?
      transaction
    rescue OWHDWallet::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    # Only **C-20 transaction
    def prepare_deposit_collection!(transaction, deposit_spread, deposit_currency)
      # Don't prepare for deposit_collection in case of native token deposit.
      return [] if contract_address(deposit_currency).blank?
      return [] if deposit_spread.blank?

      options = default_fees.merge(deposit_currency.fetch(:options).filter { |k, _| k.to_s.include?('gas_limit') })
      gas_limit = options[:gas_limit].present? ? options[:gas_limit].to_i : options[:"#{token_name}_gas_limit"]

      response = client.rest_api(:post, '/tx/before_collect', {
        coin_type: coin_type,
        gas_limit: gas_limit,
        gas_speed: wallet_gas_speed,
        spread_size: deposit_spread.size,
        to: transaction.to_address,
        gateway_url: wallet_gateway_url,
        wallet_index: wallet_index,
        passphrase: wallet_secret
      })

      transaction.currency_id = native_currency_id if transaction.currency_id.blank?
      transaction.hash = response['tx']
      transaction.options = {}
      transaction.options[:gas_limit] = gas_limit
      transaction.options[:gas_price] = response['gas_price']
      [transaction]
    rescue OWHDWallet::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def load_balance!
      response = client.rest_api(:post, '/wallet/balance', {
        coin_type: coin_type,
        gateway_url: wallet_gateway_url,
        address: wallet_address,
        contract_address: contract_address
      }.compact).fetch('balance')

      response = response.yield_self { |amount| convert_from_base_unit(amount) } if eth_like?

      response.to_d
    rescue OWHDWallet::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    private

    def eth_transaction_params(transaction, options)
      currency_options = @currency.fetch(:options).slice(:gas_limit)
      options.merge!(currency_options, default_fees)

      if transaction.options.present? && transaction.options[:gas_price]
        gas_price = transaction.options[:gas_price]
      else
        gas_speed = wallet_gas_speed
      end

      params = {
        gas_price: gas_price,
        gas_speed: gas_speed,
        subtract_fee: options.dig(:subtract_fee).present?
      }.compact!

      if contract_address.present?
        gas_limit = options[:gas_limit].present? ? options[:gas_limit].to_i : options[:"#{token_name}_gas_limit"]

        params.merge!(contract_address: contract_address, gas_limit: gas_limit)
      else
        params[:gas_limit] = options[:gas_limit].present? ? options[:gas_limit].to_i : options[:"#{coin_type}_gas_limit"]
      end

      params
    end

    def coin_type
      currency_id
    end

    def eth_like?
      false
    end

    def convert_to_base_unit(value)
      x = value.to_d * @currency.fetch(:base_factor)
      unless (x % 1).zero?
        raise Peatio::Wallet::ClientError,
              'Failed to convert value to base (smallest) unit because it exceeds the maximum precision: ' \
              "#{value.to_d} - #{x.to_d} must be equal to zero."
      end
      x.to_i
    end

    def convert_from_base_unit(value)
      value.to_d / @currency.fetch(:base_factor)
    end

    def contract_address(currency = @currency)
      currency.dig(:options, :"#{token_name}_contract_address")
    end

    def wallet_secret
      @wallet.fetch(:secret)
    end

    def wallet_index
      @wallet.fetch(:wallet_index)
    end

    def wallet_gateway_url
      @wallet.fetch(:gateway_url)
    end

    def wallet_address
      @wallet.fetch(:address)
    end

    def wallet_gas_speed
      GAS_SPEEDS.include?(@wallet[:gas_speed]) ? @wallet[:gas_speed] : 'standard'
    end

    def currency_id
      @currency.fetch(:id)
    end

    def client
      @client ||= Client.new(@wallet.fetch(:uri), idle_timeout: 1)
    end
  end
end
