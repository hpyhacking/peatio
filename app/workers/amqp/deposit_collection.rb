# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class DepositCollection < Base
      def process(payload)
        Rails.logger.info { "Received request for deposit collection at #{Time.now} deposit_id: #{payload['id']}." }
        deposit = Deposit.find_by_id(payload['id'])

        unless deposit
          Rails.logger.warn { "The deposit with id: #{payload['id']} doesn't exist."}
          return
        end

        Rails.logger.info { "Deposit amount: #{deposit.amount}, deposit address: #{deposit.address} " }

        deposit.with_lock do
          if deposit.collected?
            Rails.logger.warn { "The deposit is now being processed by different worker or has been already processed. Skipping..." }
            return
          end

          if deposit.spread.blank?
            deposit.spread_between_wallets!
            Rails.logger.warn { "The deposit was spreaded in the next way: #{deposit.spread}"}
          end

          wallet = Wallet.active.deposit.find_by(currency_id: deposit.currency_id)

          unless wallet
            Rails.logger.warn { "Can't find active deposit wallet for currency with code: #{deposit.currency_id}."}
            return
          end
          Rails.logger.warn { "Starting collecting deposit with id: #{deposit.id}." }


          transactions = WalletService.new(wallet).collect_deposit!(deposit, deposit.spread_to_transactions)

          # Save txids in deposit spread.
          deposit.update!(spread: transactions.map(&:as_json))

          Rails.logger.warn { "The API accepted deposit collection and assigned transaction ID: #{transactions.map(&:as_json)}." }

          deposit.dispatch!
        rescue Exception => e
          begin
            Rails.logger.error { "Failed to collect deposit #{deposit.id}. See exception details below." }
            report_exception(e)
          ensure
            deposit.skip!
            Rails.logger.warn { "Deposit skipped." }
          end
          raise e if is_db_connection_error?(e)
        end
      end
    end
  end
end
