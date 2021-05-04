# frozen_string_literal: true

module API
  module V2
    module WebhooksHelpers
      def process_webhook_event(request)
        if request.params[:event] == 'deposit'
          process_deposit_event(request)
        elsif request.params[:event] == 'withdraw'
          process_withdraw_event(request)
        elsif request.params[:event] == 'deposit_address'
          process_deposit_address_event(request)
        elsif request.params[:event] == 'generic'
          process_generic_event(request)
        end
      end

      def process_generic_event(request)
        Wallet.active_retired.where(kind: :deposit, gateway: request.params[:adapter]).each do |w|
          service = w.service
          next unless service.adapter.respond_to?(:trigger_webhook_event)

          transactions = service.trigger_webhook_event(request)
          next unless transactions.present?

          # Process all deposit transactions
          accepted_deposits = []
          ActiveRecord::Base.transaction do
            accepted_deposits = process_deposit(transactions, w.blockchain_key)
          end
          accepted_deposits.each(&:process!) if accepted_deposits.present?

          # Process all withdrawal transactions
          ActiveRecord::Base.transaction do
            update_generic_withdrawal(transactions)
          end
        end
      end

      def process_deposit_address_event(request)
        # For deposit address events we use only Deposit wallets.
        Wallet.where(status: :active, kind: :deposit, gateway: request.params[:adapter]).each do |w|
          service = w.service

          next unless service.adapter.respond_to?(:trigger_webhook_event)
          event = service.trigger_webhook_event(request)

          next unless event.present?

          create_address(event[:address_id], event[:address], event[:currency_id], w.blockchain_key)
        end
      end

      def process_deposit_event(request)
        # For deposit events we use only Deposit wallets.
        Wallet.active_retired.where(kind: :deposit, gateway: request.params[:adapter]).each do |w|
          service = w.service

          next unless service.adapter.respond_to?(:trigger_webhook_event)
          transactions = service.trigger_webhook_event(request)

          next unless transactions.present?

          accepted_deposits = []
          ActiveRecord::Base.transaction do
            accepted_deposits = process_deposit(transactions, w.blockchain_key)
          end
          accepted_deposits.each(&:process!) if accepted_deposits.present?
        end
      end

      def process_withdraw_event(request)
        # For withdraw events we use only Withdraw events.
        Wallet.active_retired.where(kind: :hot, gateway: request.params[:adapter]).each do |w|
          service = w.service

          next unless service.adapter.respond_to?(:trigger_webhook_event)
          transactions = service.trigger_webhook_event(request)

          next unless transactions.present?

          ActiveRecord::Base.transaction do
            update_withdrawal(transactions)
          end
        end
      end

      def process_deposit(transactions, blockchain_key)
        accepted_deposits = find_or_create_deposit!(transactions, blockchain_key)

        accepted_deposits.compact if accepted_deposits.present?
      end

      def find_or_create_deposit!(transactions, blockchain_key)
        transactions.map do |transaction|
          payment_address = PaymentAddress.find_by(wallet: Wallet.deposit_wallets(transaction.currency_id, blockchain_key), address: transaction.to_address)
          next if payment_address.blank?

          Rails.logger.info { "Deposit transaction detected: #{transaction.inspect}" }

          if transaction.options.present? && transaction.options[:tid].present?
            deposit = Deposits::Coin.find_by(tid: transaction.options[:tid])
            if deposit.present? && deposit.txid.blank?
              deposit.txid = transaction.hash
              deposit.save!
            end
          end

          if transaction.options.present? &&
             transaction.options[:remote_id].present? &&
             transaction.hash.empty?
            next
          end

          deposit =
            Deposits::Coin.find_or_create_by!(
              currency_id: transaction.currency_id,
              txid: transaction.hash,
              txout: transaction.txout,
              blockchain_key: payment_address.blockchain_key
            ) do |d|
              d.address = transaction.to_address
              d.amount = transaction.amount
              d.member = payment_address.member
              d.block_number = transaction.block_number
            end
          # TODO: check if block number changed.

          if transaction.status.success?
            deposit.accept!
          elsif transaction.status.rejected?
            deposit.reject!
          end
          deposit
        end
      end

      def update_withdrawal(transactions)
        transactions.each do |transaction|
          if transaction.options.present? && transaction.options[:tid].present?
            withdraw = Withdraws::Coin.find_by(tid: transaction.options[:tid])
            if withdraw.present? && withdraw.txid.blank?
              withdraw.txid = transaction.hash
              withdraw.save!
              withdraw.dispatch!
            end
          end

          withdrawal = Withdraws::Coin.confirming
                                      .find_by(currency_id: transaction.currency_id, txid: transaction.hash)

          if withdrawal.blank?
            Rails.logger.info { "Skipped withdrawal: #{transaction.hash}." }
            next
          end

          Rails.logger.info { "Withdraw transaction detected: #{transaction.inspect}" }
          if transaction.status.failed?
            withdrawal.fail!
          elsif transaction.status.success?
            withdrawal.success!
          elsif transaction.status.rejected?
            withdrawal.reject!
          end
        end
      end

      def update_generic_withdrawal(transactions)
        transactions.each do |transaction|
          withdraw = Withdraws::Coin.find_by(remote_id: transaction.options[:remote_id])

          if withdraw.blank?
            Rails.logger.info { "Skipped withdrawal: #{transaction.hash}." }
            next
          end

          if transaction.options.present? && transaction.options[:remote_id].present?
            if withdraw.txid.blank? && transaction.hash.present?
              withdraw.txid = transaction.hash
              withdraw.save!
              withdraw.dispatch!
            end
          end

          Rails.logger.info { "Withdraw transaction detected: #{transaction.inspect}" }
          if transaction.status.failed?
            withdraw.fail!
          elsif transaction.status.success?
            withdraw.success!
          elsif transaction.status.rejected?
            withdraw.reject!
          end
        end
      end

      # This method will update payment address by specific detail value
      def create_address(address_id, address, currency_id, blockchain_key)
        Rails.logger.info { "Address detected: #{address}" }

        payment_address = PaymentAddress.where(address: nil, wallet: Wallet.deposit_wallets(currency_id, blockchain_key))
                                        .find { |address| address.details['address_id'] == address_id }

        payment_address.update!(address: address) if payment_address.present?
      end
    end
  end
end
