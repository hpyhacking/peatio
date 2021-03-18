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
        end
      end

      def process_deposit_address_event(request)
        # For deposit address events we use only Deposit wallets.
        Wallet.where(status: :active, kind: :deposit, gateway: request.params[:adapter]).each do |w|
          service = w.service

          next unless service.adapter.respond_to?(:trigger_webhook_event)
          event = service.trigger_webhook_event(request)

          next unless event.present?

          create_address(event[:details], event[:address], event[:currency_id])
        end
      end

      def process_deposit_event(request)
        # For deposit events we use only Deposit wallets.
        Wallet.where(status: :active, kind: :deposit, gateway: request.params[:adapter]).each do |w|
          service = w.service

          next unless service.adapter.respond_to?(:trigger_webhook_event)
          transactions = service.trigger_webhook_event(request)

          next unless transactions.present?

          accepted_deposits = []
          ActiveRecord::Base.transaction do
            accepted_deposits = process_deposit(transactions)
          end
          accepted_deposits.each(&:process!) if accepted_deposits.present?
        end
      end

      def process_withdraw_event(request)
        # For withdraw events we use only Withdraw events.
        Wallet.where(status: :active, kind: :hot, gateway: request.params[:adapter]).each do |w|
          service = w.service

          next unless service.adapter.respond_to?(:trigger_webhook_event)
          transactions = service.trigger_webhook_event(request)

          next unless transactions.present?

          ActiveRecord::Base.transaction do
            update_withdrawal(transactions)
          end
        end
      end

      def process_deposit(transactions)
        accepted_deposits = find_or_create_deposit!(transactions)

        accepted_deposits.compact if accepted_deposits.present?
      end

      def find_or_create_deposit!(transactions)
        transactions.map do |transaction|
          payment_address = PaymentAddress.find_by(wallet: Wallet.deposit_wallet(transaction.currency_id), address: transaction.to_address)
          next if payment_address.blank?

          Rails.logger.info { "Deposit transaction detected: #{transaction.inspect}" }

          if transaction.options.present? && transaction.options[:tid].present?
            deposit = Deposits::Coin.find_by(tid: transaction.options[:tid])
            if deposit.present? && deposit.txid.blank?
              deposit.txid = transaction.hash
              deposit.save!
            end
          end

          deposit =
            Deposits::Coin.find_or_create_by!(
              currency_id: transaction.currency_id,
              txid: transaction.hash,
              txout: transaction.txout
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

      # This method will update payment address by specific detail value
      def create_address(details, address, currency_id)
        Rails.logger.info { "Address detected: #{address}" }

        key_name = details.keys.first.to_s
        key_value = details.values.first
        payment_address = PaymentAddress.where(address: nil, wallet: Wallet.deposit_wallet(currency_id))
                                        .find { |address| address.details[key_name] == key_value }

        payment_address.update!(address: address) if payment_address.present?
      end
    end
  end
end
