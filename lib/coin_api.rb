module CoinAPI
  Error                  = Class.new(StandardError)
  ConnectionRefusedError = Class.new(StandardError)

  class << self
    #
    # Returns API client for given currency code.
    #
    # @param code [String, Symbol]
    #   The currency code. May be uppercase or lowercase.
    # @return [BaseAPI]
    def [](code)
      currency = Currency.find_by_code(code.to_s.downcase)
      raise Error, "Couldn't find currency with code #{code.inspect}." unless currency

      if currency.try(:api_client).present?
        "CoinAPI::#{currency.api_client.camelize}"
      else
        "CoinAPI::#{code.upcase}"
      end.constantize.new(currency)
    end
  end

  class BaseAPI
    extend Memoist

    #
    # Returns the currency.
    #
    # @return [Currency]
    attr_reader :currency

    #
    # Returns hot wallet address.
    #
    # @return [String]
    delegate :hot_wallet_address, to: :currency

    def initialize(currency)
      @currency = currency
    end

    #
    # Returns hot wallet balance.
    #
    # @abstract Derived API clients must implement it.
    # @return [BigDecimal]
    def load_balance!
      method_not_implemented
    end

    #
    # TODO: Docs.
    #
    # @abstract Derived API clients must implement it.
    # @return [Array<Hash>]
    def each_deposit
      method_not_implemented
    end

    #
    # TODO: Docs.
    #
    # @abstract Derived API clients must implement it.
    # @return [Array<Hash>]
    def each_deposit!
      method_not_implemented
    end

    #
    # Returns transaction details.
    #
    # TODO: Docs.
    #
    # @param txid [String]
    # @return [Hash]
    #   The deposit details.
    def load_deposit!(txid)
      method_not_implemented
    end

    #
    # Created new address.
    #
    # TODO: Doc.
    #
    def create_address!
      method_not_implemented
    end

    #
    # Creates new withdrawal and returns transaction ID.
    #
    # TODO: Doc.
    #
    def create_withdrawal!(issuer, recipient, amount, fee)
      method_not_implemented
    end

    # TODO: Doc.
    def inspect_address!(address)
      method_not_implemented
    end

    %i[ load_balance load_deposit create_address create_withdrawal inspect_address ].each do |method|
      class_eval <<-RUBY
        def #{method}(*args, &block)
          silencing_exception { #{method}!(*args, &block) }
        end
      RUBY
    end

  protected

    def silencing_exception
      yield
    rescue => e
      report_exception(e)
      nil
    end
  end
end
