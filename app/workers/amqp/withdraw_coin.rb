# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class WithdrawCoin
      def initialize
        @logger = TaggedLogger.new(Rails.logger, worker: __FILE__)
      end

      def process(payload)
        payload.symbolize_keys!

        @logger.warn id: payload[:id], message: 'Received request for processing withdraw.'

        withdraw = Withdraw.find_by_id(payload[:id])
        if withdraw.blank?
          @logger.warn id: payload[:id], message: 'The withdraw with such ID doesn\'t exist in database.'
          return
        end

        withdraw.with_lock do
          unless withdraw.processing?
            @logger.warn id: withdraw.id,
                         message: 'The withdraw is being processed by another worker or has already been processed.'
            return
          end

          if withdraw.rid.blank?
            @logger.warn id: withdraw.id,
                         message: 'The destination address doesn\'t exist.'
            withdraw.fail!
            return
          end

          @logger.warn id: withdraw.id,
                       amount: withdraw.amount.to_s('F'),
                       fee: withdraw.fee.to_s('F'),
                       currency: withdraw.currency.code.upcase,
                       rid: withdraw.rid,
                       message: 'Sending witdraw.'

          wallet = Wallet.active.withdraw
                         .find_by(currency_id: withdraw.currency_id, kind: :hot)

          unless wallet
            @logger.warn id: withdraw.id,
                         currency: withdraw.currency.code.upcase,
                         message: 'Can\'t find active hot wallet for currency.'
            withdraw.skip!
            return
          end

          balance = wallet.current_balance
          if balance == 'N/A' || balance < withdraw.amount
            @logger.warn id: withdraw.id,
                         balance: balance.to_s,
                         amount: withdraw.amount.to_s,
                         message: 'The withdraw skipped because wallet balance is not sufficient or amount greater than wallet max_balance.'
            return withdraw.skip!
          end

          @logger.warn id: withdraw.id,
                       message: 'Sending request to Wallet Service.'

          wallet_service = WalletService.new(wallet)
          transaction = wallet_service.build_withdrawal!(withdraw)

          @logger.warn id: withdraw.id,
                       tid: transaction.hash,
                       message: 'The currency API accepted withdraw and assigned transaction ID.'

          @logger.warn id: withdraw.id,
                       message: 'Updating withdraw state in database.'

          withdraw.txid = transaction.hash
          withdraw.dispatch
          withdraw.save!

          @logger.warn id: withdraw.id, message: 'OK.'

        rescue Exception => e
          begin
            @logger.error id: withdraw.id,
                          message: 'Failed to process withdraw. See exception details below.'
            report_exception(e)
          ensure
            if withdraw.may_process?
              @logger.warn id: withdraw.id,
                           message: "Retring to process withdraw. Attempt ##{withdraw.attempts}"
              withdraw.process!
            else
              @logger.warn id: withdraw.id,
                           message: 'Setting withdraw state to failed.'
              withdraw.fail!
            end
            @logger.warn id: withdraw.id, message: 'OK.'
          end
        end
      end
    end
  end
end
