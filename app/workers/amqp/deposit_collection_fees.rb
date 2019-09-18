# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class DepositCollectionFees < Base
      def process(payload)
        Rails.logger.info { "Received request for deposit collection fees transfer id: #{payload['id']}." }
        deposit = Deposit.find_by_id(payload['id'])

        unless deposit
          Rails.logger.warn { "The deposit with id: #{payload['id']} doesn't exist."}
          return
        end

        deposit.with_lock do
          if deposit.collected?
            Rails.logger.warn { "The deposit is now being processed by different worker or has been already processed. Skipping..." }
            return
          end


          if deposit.spread.blank?
            deposit.spread_between_wallets!
            Rails.logger.warn { "The deposit was spreaded in the next way: #{deposit.spread}"}
          end

          wallet = Wallet.active.fee.find_by(blockchain_key: deposit.currency.blockchain_key)
          unless wallet
            Rails.logger.warn { "Can't find active deposit wallet for currency with code: #{deposit.currency_id}."}
            AMQPQueue.enqueue(:deposit_collection, id: deposit.id)
            return
          end

          transactions = WalletService.new(wallet).deposit_collection_fees!(deposit, deposit.spread_to_transactions)

          if transactions.present?
            Rails.logger.warn { "The API accepted deposit collection fees transfer and assigned transaction IDs: #{transactions.map(&:as_json)}." }
          end

          AMQPQueue.enqueue(:deposit_collection, id: deposit.id)
          Rails.logger.warn { "Deposit collection job enqueue." }
        rescue Exception => e
          begin
            Rails.logger.error { "Failed to collect fee transfer deposit #{deposit.id}. See exception details below." }
            report_exception(e)
          ensure
            deposit.skip!
            Rails.logger.error { "Exit..." }
          end

          raise e if is_db_connection_error?(e)
        end
      end
    end
  end
end
