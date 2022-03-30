# frozen_string_literal: true

module Jobs
  module Cron
    module WithdrawWatcher
      class << self
        def process
          process_under_review_withdrawals
          process_confirming_withdrawals
          sleep 25
        end

        def process_under_review_withdrawals
          ::Withdraws::Coin.under_review.each do |withdraw|
            @service = nil

            Rails.logger.info { "Starting processing coin withdraw with id: #{withdraw.id}." }

            unless withdraw.remote_id
              Rails.logger.warn { "Withdraw with id: #{withdraw.id} and state: #{withdraw.aasm_state} does not have a remote_id, skipping." }
              next
            end

            wallet = Wallet.active.joins(:currencies)
                           .find_by(currencies: { id: withdraw.currency_id }, kind: :hot)

            unless wallet
              Rails.logger.warn { "Can't find active hot wallet for currency with code: #{withdraw.currency_id}." }
              next
            end

            @service = WalletService.new(wallet)
            # Check if adapter has fetch_blockchain_transaction_id implementation
            next unless wallet.gateway_implements?(:fetch_blockchain_transaction_id)

            begin
              configure_service_adapter(withdraw)
              fetch_withdraw_txid(withdraw)
              Rails.logger.warn "Txid for withdraw #{withdraw.id} is not available" if withdraw.txid.nil?
            rescue StandardError => e
              Rails.logger.error { "Failed to fetch txId for withdraw #{withdraw.id}. See exception details below." }
              report_exception(e)
              raise e if is_db_connection_error?(e)
            end
          end
        end

        def process_confirming_withdrawals
          ::Withdraws::Coin.confirming.each do |withdraw|
            @service = nil

            unless withdraw.remote_id
              Rails.logger.warn { "Withdraw with id: #{withdraw.id} and state: #{withdraw.aasm_state} does not have a remote_id, skipping." }
              next
            end

            wallet = Wallet.active.joins(:currencies)
                           .find_by(currencies: { id: withdraw.currency_id }, kind: :hot)

            unless wallet
              Rails.logger.warn { "Can't find active hot wallet for currency with code: #{withdraw.currency_id}." }
              next
            end

            @service = WalletService.new(wallet)
            # Check if adapter has fetch_withdraw_status implementation
            next unless wallet.gateway_implements?(:fetch_withdraw_status)

            begin
              configure_service_adapter(withdraw)
              update_withdraw_status(withdraw)
            rescue StandardError => e
              Rails.logger.error { "Failed to update withdraw #{withdraw.id} status. See exception details below." }
              report_exception(e)
              raise e if is_db_connection_error?(e)
            end
          end
        end

        def configure_service_adapter(withdraw)
          blockchain_currency = BlockchainCurrency.find_network(withdraw.blockchain_key, withdraw.currency.id)
          @service.adapter.configure(wallet: @service.wallet.to_wallet_api_settings,
                                     currency: blockchain_currency.to_blockchain_api_settings)
        end

        def fetch_withdraw_txid(withdraw)
          tx = fetch_withdraw_status(withdraw)
          if tx.status.failed?
            withdraw.fail!
            return
          elsif tx.status.rejected?
            withdraw.reject!
            return
          end

          withdraw.txid = @service.adapter.fetch_blockchain_transaction_id(withdraw.remote_id)
          return if withdraw.txid.blank?

          withdraw.save!
          withdraw.dispatch!
        end

        def fetch_withdraw_status(withdraw)
          tx = Peatio::Transaction.new
          tx.status = @service.adapter.fetch_withdraw_status(withdraw.remote_id)
          return tx
        end

        def update_withdraw_status(withdraw)
          tx = fetch_withdraw_status(withdraw)

          if tx.status.success?
            withdraw.success!
          elsif tx.status.failed?
            withdraw.fail!
          elsif tx.status.rejected?
            withdraw.reject!
          end
        end

        def is_db_connection_error?(exception)
          exception.is_a?(Mysql2::Error::ConnectionError) || exception.cause.is_a?(Mysql2::Error)
        end
      end
    end
  end
end
