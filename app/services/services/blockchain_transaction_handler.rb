# encoding: UTF-8
# frozen_string_literal: true

module Services
  class BlockchainTransactionHandler
    attr_reader :currency

    def initialize(currency)
      @currency = currency
    end

    def call(tx)
      # Skip if transaction is processed.
      return if Deposits::Coin.where(currency: currency, txid: tx[:id]).exists?

      # Skip transactions for which addresses don't exist in database.
      # At least one address from transaction entries must exist in Peatio database.
      recipients = tx[:entries].map { |entry| entry[:address] }
      return unless recipients.find { |address| PaymentAddress.where(currency: currency, address: address).exists? }

      Rails.logger.info { "Missed #{currency.code.upcase} transaction: #{tx[:id]}." }

      # Immediately enqueue job.
      AMQPQueue.enqueue :deposit_coin, { txid: tx[:id], currency: currency.code }
    rescue => e
      report_exception(e)
    end
  end
end
