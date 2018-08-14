# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns WalletService for given wallet.
    #
    # @param wallet [String, Symbol]
    #   The wallet record in database.
    def [](wallet)
      wallet_service = wallet.gateway.capitalize
      "WalletService::#{wallet_service}"
        .constantize
        .new(wallet)
    rescue NameError
      raise Error, "Wrong WalletService name #{wallet_service}"
    end
  end

  class Base

    attr_accessor :wallet, :client

    def initialize(wallet)
      @wallet = wallet
      @client = WalletClient[wallet]
    end

    def collect_deposit!(deposit)
      method_not_implemented
    end

    # TODO: Rename this method.
    def build_withdrawal!(withdraw)
      method_not_implemented
    end

    # TODO: Rename this method.
    def create_address!
      method_not_implemented
    end

    protected

    def destination_wallet(deposit)
      # TODO: Dynamicly check wallet balance and select destination wallet.
      # For keeping it simple we will collect all deposits to hot wallet.
      Wallet
        .active
        .withdraw
        .find_by(currency_id: deposit.currency_id, kind: :hot)
    end
  end
end
