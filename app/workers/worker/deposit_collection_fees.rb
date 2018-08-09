# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class DepositCollectionFees
    def process(payload)
      Rails.logger.info { "Received request for deposit collection fees transfer id: #{payload['id']}." }
      deposit = Deposit.find_by_id(payload['id'])

      unless deposit
        Rails.logger.warn { "The deposit with id: #{payload['id']} doesn't exist."}
        return
      end

      wallet = Wallet.active.deposit.find_by(blockchain_key: deposit.currency.blockchain_key)
      unless wallet
        Rails.logger.warn { "Can't find active deposit wallet for currency with code: #{deposit.currency_id}."}
        return
      end

      txid = WalletService[wallet].deposit_collection_fees(deposit)
      Rails.logger.warn { "The API accepted deposit collection fees transfer and assigned transaction ID: #{txid}." }
      AMQPQueue.enqueue(:deposit_collection, id: deposit.id)
      Rails.logger.warn { "Deposit collection job enqueue." }
    rescue => e
      report_exception(e)
      raise e
    end
  end
end
