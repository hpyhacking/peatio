module Ethereum
  class WalletAbstract < Peatio::Wallet::Abstract

    DEFAULT_ETH_FEE = { gas_limit: 21_000, gas_price: :standard }.freeze

    DEFAULT_ERC20_FEE = { gas_limit: 90_000, gas_price: :standard }.freeze

    DEFAULT_FEATURES = { skip_deposit_collection: false }.freeze

    GAS_SPEEDS = { standard: 1, safelow: 0.9, fast: 1.1 }.freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def contract_address_option
      :"#{token_name}_contract_address"
    end

    def configure(settings = {})
      # Clean client state during configure.
      @client = nil

      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))

      @wallet = @settings.fetch(:wallet) do
        raise Peatio::Wallet::MissingSettingError, :wallet
      end.slice(:uri, :address, :secret)

      @currency = @settings.fetch(:currency) do
        raise Peatio::Wallet::MissingSettingError, :currency
      end.slice(:id, :base_factor, :min_collection_amount, :options)
    end

    def create_address!(options = {})
      secret = options.fetch(:secret) { PasswordGenerator.generate(64) }
      secret.yield_self do |password|
        { address: normalize_address(client.json_rpc(:personal_newAccount, [password])),
          secret:  password }
      end
    rescue Ethereum::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def create_transaction!(transaction, options = {})
      if @currency.dig(:options, contract_address_option).present?
        create_erc20_transaction!(transaction)
      elsif @currency[:id] == native_currency_id
        create_eth_transaction!(transaction, options)
      else
        raise Peatio::Wallet::ClientError.new("Currency #{@currency[:id]} doesn't have option #{contract_address_option}")
      end
    rescue Ethereum::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def prepare_deposit_collection!(transaction, deposit_spread, deposit_currency)
      # Don't prepare for deposit_collection in case of eth deposit.
      return [] if deposit_currency.dig(:options, contract_address_option).blank?
      return [] if deposit_spread.blank?

      options = DEFAULT_ERC20_FEE.merge(deposit_currency.fetch(:options).slice(:gas_limit, :gas_price))

      options[:gas_price] = calculate_gas_price(options)

      # We collect fees depending on the number of spread deposit size
      # Example: if deposit spreads on three wallets need to collect eth fee for 3 transactions
      fees = convert_from_base_unit(options.fetch(:gas_limit).to_i * options.fetch(:gas_price).to_i)
      amount = fees * deposit_spread.size

      # If fee amount is greater than min collection amount
      # system will detect fee collection as deposit
      # To prevent this system will raise an error
      min_collection_amount = @currency.fetch(:min_collection_amount).to_d
      if amount > min_collection_amount
        raise Ethereum::Client::Error, \
              "Fee amount(#{amount}) is greater than min collection amount(#{min_collection_amount})."
      end

      transaction.amount = amount
      transaction.options = options

      [create_eth_transaction!(transaction)]
    rescue Ethereum::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    def load_balance!
      if @currency.dig(:options, contract_address_option).present?
        load_erc20_balance(@wallet.fetch(:address))
      elsif @currency[:id] == native_currency_id
        client.json_rpc(:eth_getBalance, [normalize_address(@wallet.fetch(:address)), 'latest'])
        .hex
        .to_d
        .yield_self { |amount| convert_from_base_unit(amount) }
      else
        raise Peatio::Wallet::ClientError.new("Currency #{@currency[:id]} doesn't have option #{contract_address_option}")
      end
    rescue Ethereum::Client::Error => e
      raise Peatio::Wallet::ClientError, e
    end

    protected

    def load_erc20_balance(address)
      data = abi_encode('balanceOf(address)', normalize_address(address))
      client.json_rpc(:eth_call, [{ to: contract_address, data: data }, 'latest'])
        .hex
        .to_d
        .yield_self { |amount| convert_from_base_unit(amount) }
    end

    def create_eth_transaction!(transaction, options = {})
      currency_options = @currency.fetch(:options).slice(:gas_limit, :gas_price)
      options.merge!(DEFAULT_ETH_FEE, currency_options)

      amount = convert_to_base_unit(transaction.amount)

      if transaction.options.present?
        options[:gas_price] = transaction.options[:gas_price]
      else
        options[:gas_price] = calculate_gas_price(options)
      end

      # Subtract fees from initial deposit amount in case of deposit collection
      amount -= options.fetch(:gas_limit).to_i * options.fetch(:gas_price).to_i if options.dig(:subtract_fee)

      txid = client.json_rpc(:personal_sendTransaction,
                  [{
                      from:     normalize_address(@wallet.fetch(:address)),
                      to:       normalize_address(transaction.to_address),
                      value:    '0x' + amount.to_s(16),
                      gas:      '0x' + options.fetch(:gas_limit).to_i.to_s(16),
                      gasPrice: '0x' + options.fetch(:gas_price).to_i.to_s(16)
                    }.compact, @wallet.fetch(:secret)])

      unless valid_txid?(normalize_txid(txid))
        raise Ethereum::Client::Error, \
              "Withdrawal from #{@wallet.fetch(:address)} to #{transaction.to_address} failed."
      end

      # Make sure that we return currency_id
      transaction.currency_id = 'eth' if transaction.currency_id.blank?
      transaction.amount = convert_from_base_unit(amount)
      transaction.hash = normalize_txid(txid)
      transaction.options = options
      transaction
    end

    def create_erc20_transaction!(transaction, options = {})
      currency_options = @currency.fetch(:options).slice(:gas_limit, :gas_price, contract_address_option)
      options.merge!(DEFAULT_ERC20_FEE, currency_options)

      amount = convert_to_base_unit(transaction.amount)
      data = abi_encode('transfer(address,uint256)',
                        normalize_address(transaction.to_address),
                        '0x' + amount.to_s(16))

      if transaction.options.present?
        options[:gas_price] = transaction.options[:gas_price]
      else
        options[:gas_price] = calculate_gas_price(options)
      end

      txid = client.json_rpc(:personal_sendTransaction,
                [{
                    from:     normalize_address(@wallet.fetch(:address)),
                    to:       options.fetch(contract_address_option),
                    data:     data,
                    gas:      '0x' + options.fetch(:gas_limit).to_i.to_s(16),
                    gasPrice: '0x' + options.fetch(:gas_price).to_i.to_s(16)
                  }.compact, @wallet.fetch(:secret)])

      unless valid_txid?(normalize_txid(txid))
        raise Ethereum::Client::Error, \
              "Withdrawal from #{@wallet.fetch(:address)} to #{transaction.to_address} failed."
      end

      transaction.hash = normalize_txid(txid)
      transaction.options = options
      transaction
    end

    def normalize_address(address)
      address.downcase
    end

    def normalize_txid(txid)
      txid.downcase
    end

    def contract_address
      normalize_address(@currency.dig(:options, contract_address_option))
    end

    def valid_txid?(txid)
      txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    end

    def abi_encode(method, *args)
      '0x' + args.each_with_object(Digest::SHA3.hexdigest(method, 256)[0...8]) do |arg, data|
        data.concat(arg.gsub(/\A0x/, '').rjust(64, '0'))
      end
    end

    def convert_from_base_unit(value)
      value.to_d / @currency.fetch(:base_factor)
    end

    def convert_to_base_unit(value)
      x = value.to_d * @currency.fetch(:base_factor)
      unless (x % 1).zero?
        raise Peatio::Wallet::ClientError,
            "Failed to convert value to base (smallest) unit because it exceeds the maximum precision: " \
            "#{value.to_d} - #{x.to_d} must be equal to zero."
      end
      x.to_i
    end

    def calculate_gas_price(options = { gas_price: :standard })
      # Get current gas price
      gas_price = client.json_rpc(:eth_gasPrice, [])
      Rails.logger.info { "Current gas price #{gas_price.to_i(16)}" }

      # Apply thresholds depending on currency configs by default it will be standard
      (gas_price.to_i(16) * GAS_SPEEDS.fetch(options[:gas_price].try(:to_sym), 1)).to_i
    end

    def client
      uri = @wallet.fetch(:uri) { raise Peatio::Wallet::MissingSettingError, :uri }
      @client ||= Client.new(uri, idle_timeout: 1)
    end
  end
end
