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
            # Check if adapter has withdraw_confirmed? implementation
            next unless wallet.gateway_implements?(:withdraw_confirmed?)

            begin
              configure_service_adapter(withdraw)
              confirm_withdraw(withdraw)
            rescue StandardError => e
              Rails.logger.error { "Failed to confirm withdraw #{withdraw.id}. See exception details below." }
              report_exception(e)
              raise e if is_db_connection_error?(e)
            end
          end
        end

        def configure_service_adapter(withdraw)
          @service.adapter.configure(wallet: @service.wallet.to_wallet_api_settings,
                                     currency: withdraw.currency.to_blockchain_api_settings)
        end

        def fetch_withdraw_txid(withdraw)
          withdraw.txid = @service.adapter.fetch_blockchain_transaction_id(withdraw.remote_id)
          return if withdraw.txid.blank?

          withdraw.save!
          withdraw.dispatch!
        end

        def confirm_withdraw(withdraw)
          withdraw.success! if @service.adapter.withdraw_confirmed?(withdraw.remote_id)
        end

        def is_db_connection_error?(exception)
          exception.is_a?(Mysql2::Error::ConnectionError) || exception.cause.is_a?(Mysql2::Error)
        end
      end
    end
  end
end
