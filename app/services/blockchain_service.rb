# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns Service for given blockchain key.
    #
    # @param key [String, Symbol]
    #   The blockchain key.
    def [](key)
      blockchain = Blockchain.find_by_key(key)
      if blockchain.try(:client).present?
        "BlockchainService::#{blockchain.client.capitalize}"
      end.constantize.new(blockchain)
    end
  end

  class Base

    attr_reader :blockchain, :client

    def initialize(blockchain)
      @blockchain = blockchain
      @client     = BlockchainClient[blockchain.key]
    end

    protected

    def save_block(block, latest_block_number)
      block[:deposits].map { |d| d[:txid] }.join(',').tap do |txids|
        Rails.logger.info { "Deposit trancations in block #{block[:id]}: #{txids}" }
      end

      block[:withdrawals].map { |d| d[:txid] }.join(',').tap do |txids|
        Rails.logger.info { "Withdraw trancations in block #{block[:id]}: #{txids}" }
      end

      ActiveRecord::Base.transaction do
        update_or_create_deposits!(block[:deposits])
        update_withdrawals!(block[:withdrawals])
        update_height(block[:id], latest_block_number)
      end
    end

    def update_or_create_deposits!(deposits)
      deposits.each do |deposit_hash|
        # If deposit doesn't exist create it.
        deposit = Deposits::Coin
                    .where(currency: currencies)
                    .find_or_create_by!(deposit_hash.slice(:txid)) do |deposit|
                      deposit.assign_attributes(deposit_hash)
                    end

        deposit.update_column(:block_number, deposit_hash.fetch(:block_number))
        deposit.accept! if deposit.confirmations >= blockchain.min_confirmations
      end
    end

    def update_withdrawals!(withdrawals)
      withdrawals.each do |withdrawal_hash|

        withdrawal = Withdraws::Coin
                       .confirming
                       .where(currency: currencies)
                       .find_by(withdrawal_hash.slice(:txid)) do |withdrawal|
                         withdrawal.assign_attributes(withdrawal_hash)
                       end

        # Skip non-existing in database withdrawals.
        if withdrawal.blank?
          Rails.logger.info { "Skipped withdrawal: #{withdrawal_hash[:txid]}." }
          next
        end

        withdrawal.update_column(:block_number, withdrawal_hash.fetch(:block_number))
        withdrawal.success! if withdrawal.confirmations >= blockchain.min_confirmations
      end
    end

    def update_height(block_id, latest_block)
      raise Error, "#{blockchain.name} height was reset." if blockchain.height != blockchain.reload.height
      blockchain.update(height: block_id) if latest_block - block_id >= blockchain.min_confirmations
    end

    def currencies
      blockchain.currencies
    end

    def payment_addresses_where(options = {})
      options = { currency: currencies }.merge(options)
      PaymentAddress
        .includes(:currency)
        .where(options)
        .each do |payment_address|
          yield payment_address if block_given?
        end
    end

    def wallets_where(options = {})
      options = { currency: currencies,
                  kind: %i[cold warm hot] }.merge(options)
      Wallet
        .includes(:currency)
        .where(options)
        .each do |wallet|
          yield wallet if block_given?
        end
    end
  end
end
