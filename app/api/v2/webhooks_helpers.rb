# frozen_string_literal: true

module API
  module V2
    module WebhooksHelpers
      def proces_webhook_event(event)
        if params[:event] == 'deposit'
          # For deposit events we use only Deposit wallets.
          Wallet.where(status: :active, kind: :deposit).each do |w|
            service = w.service
            next unless service.adapter.respond_to?(:trigger_webhook_event)

            event = service.trigger_webhook_event(params)
            next unless event.present?

            accepted_deposits = []
            ActiveRecord::Base.transaction do
              accepted_deposits = process_deposit_event(event)
            end
            accepted_deposits.each(&:collect!)
          end
        elsif params[:event] == 'withdraw'
          # For withdraw events we use only Withdraw events.
          Wallet.where(status: :active, kind: :hot).each do |w|
            service = w.service
            next unless service.adapter.respond_to?(:trigger_webhook_event)

            event = service.trigger_webhook_event(params)
            next unless event.present?

            ActiveRecord::Base.transaction do
              update_withdrawal!(event[:transfers]) if event[:transfers].present?
            end
          end
        end
      end

      def process_deposit_event(event)
        if event[:transfers].present?
          accepted_deposits = find_or_create_deposit!(event[:transfers])
        elsif event[:address_confirmation].present?
          # TODO: Add Address confirmation
        end
        accepted_deposits.compact
      end

      def find_or_create_deposit!(transactions)
        transactions.map do |transaction|
          payment_address = PaymentAddress.find_by(currency_id: transaction.currency_id, address: transaction.to_address)
          next if payment_address.blank?

          Rails.logger.info { "Deposit transaction detected: #{transaction.inspect}" }
          deposit =
            Deposits::Coin.find_or_create_by!(
              currency_id: transaction.currency_id,
              txid: transaction.hash,
              txout: transaction.txout
            ) do |d|
              d.address = transaction.to_address
              d.amount = transaction.amount
              d.member = payment_address.account.member
              d.block_number = transaction.block_number
            end
          # TODO: check if block number changed.
          next unless transaction.status.success?
          deposit.accept!
          deposit
        end
      end

      def update_withdrawal!(transactions)
        transactions.each do |transaction|
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
          end
        end
      end
    end
  end
end
