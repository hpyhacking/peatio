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
          unless transactions.present?
            Rails.logger.info { "Transactions not found for wallet #{w.name} with gateway #{w.gateway}" }
            next
          end
          Rails.logger.info { "Fetched transactions: #{transactions.inspect}" }

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
        confirm_deposit_collection(transactions)
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

          # Find transaction in DB (Find transaction which connected to fee transfer to user payment addresses)
          # For erc20 transaction
          if transaction.options.present? && transaction.options[:remote_id].present?
            tx = Transaction.where(to_address: payment_address.address, blockchain_key: payment_address.blockchain_key, kind: 'tx_prebuild')
                            .select { |t| t.options['remote_id'] == transaction.options[:remote_id]}.last
          elsif transaction.hash.present?
            tx = Transaction.find_by(txid: transaction.hash, kind: 'tx_prebuild')
          end

          if tx.present?
            tx.update!(fee: transaction.fee, block_number: transaction.block_number, fee_currency_id: transaction.fee_currency_id)

            # Confirm fee collection in case of successful transaction
            if transaction.status.success?
              # Update erc20 transaction details, move deposit state to fee_collected
              tx.update(txid: transaction.hash)
              tx.reference.confirm_fee_collection!
              tx.confirm!
            elsif transaction.status.failed?
              tx.reference.err! StandardError.new 'Fee collection transaction failed'
              tx.fail!
            end
          else
            # Create or update deposit
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
      end

      def confirm_deposit_collection(transactions)
        transactions.each do |transaction|
          tx = if transaction.options.present? && transaction.options[:remote_id].present?
                  Transaction.where(currency_id: transaction.currency_id, kind: 'tx', status: 'pending')
                             .find { |t| t.options['remote_id'] == transaction.options[:remote_id] }
               elsif transaction.hash.present?
                  Transaction.find_by(txid: transaction.hash, kind: 'tx')
               end

          next if tx.blank?
          deposit = tx.reference
          if transaction.status.success? && deposit.collecting?
            tx.update!(fee: transaction.fee, block_number: transaction.block_number, fee_currency_id: transaction.fee_currency_id)

            updated_spread = deposit.spread.map do |spread_tx|
              spread_tx.deep_symbolize_keys!
              if spread_tx[:hash].present?
                spread_tx[:status] = 'succeed' if spread_tx[:hash] == transaction.hash
              elsif spread_tx[:options].present? && transaction.options.present? && spread_tx[:options][:remote_id].present?
                spread_tx[:status] = 'succeed' if spread_tx[:options][:remote_id] == transaction.options[:remote_id]
              end
              spread_tx
            end
            deposit.update(spread: updated_spread)
            deposit.dispatch! if deposit.spread.map { |t| t[:status].in?(%w[skipped succeed]) }.all?(true)
            tx.confirm!
          elsif transaction.status.failed? && deposit.collecting?
            deposit.err! StandardError.new 'Collection transaction failed'
            tx.fail!
          end
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
          # Select transaction to update txid, fee currency, fee, block number if needed
          tx = Transaction.find_by(reference: withdrawal, status: :pending)
          tx.update!(txid: transaction.hash, fee: transaction.fee, block_number: transaction.block_number, fee_currency_id: transaction.fee_currency_id)

          if transaction.status.failed?
            withdrawal.fail!
            tx.fail!
          elsif transaction.status.success?
            withdrawal.success!
            tx.confirm!
          elsif transaction.status.rejected?
            withdrawal.reject!
            tx.reject!
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

          # Select transaction to update txid, fee currency, fee, block number if needed
          tx = Transaction.find_by(reference: withdraw, status: :pending)
          tx.update!(txid: transaction.hash, fee: transaction.fee, block_number: transaction.block_number, fee_currency_id: transaction.fee_currency_id)

          Rails.logger.info { "Withdraw transaction detected: #{transaction.inspect}" }
          if transaction.status.failed?
            withdraw.fail!
            tx.fail!
          elsif transaction.status.success?
            withdraw.success!
            tx.confirm!
          elsif transaction.status.rejected?
            withdraw.reject!
            tx.reject!
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
