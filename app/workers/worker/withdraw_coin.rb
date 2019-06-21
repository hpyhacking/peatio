# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class WithdrawCoin
    def process(payload)
      payload.symbolize_keys!

      Rails.logger.warn { ">>>>> Received request for processing withdraw ##{payload[:id]}." }

      withdraw = Withdraw.find_by_id(payload[:id])

      if withdraw.blank?
        Rails.logger.warn { "The withdraw with such ID doesn't exist in database." }
        return
      end

      withdraw.with_lock do
        unless withdraw.processing?
          Rails.logger.warn { "The withdraw is now being processed by different worker or has been already processed. Skipping..." }
          return
        end

        if withdraw.rid.blank?
          Rails.logger.warn { "The destination address doesn't exist. Skipping..." }
          withdraw.fail!
          return
        end

        Rails.logger.warn { "Information: sending #{withdraw.amount.to_s("F")} (exchange fee is #{withdraw.fee.to_s("F")}) #{withdraw.currency.code.upcase} to #{withdraw.rid}." }

        wallet = Wallet.active.withdraw
                       .find_by(currency_id: withdraw.currency_id, kind: :hot)

        unless wallet
          Rails.logger.warn { "Can't find active hot wallet for currency with code: #{withdraw.currency_id}."}
          withdraw.skip!
          return
        end

        balance = wallet.current_balance
        if balance == 'N/A' || balance < withdraw.amount
          Rails.logger.warn do
            "The withdraw skipped because wallet balance is not sufficient or amount greater than wallet max_balance"\
            "wallet balance is #{balance.to_s}, wallet max balance is #{wallet.max_balance.to_s}."
          end
          return withdraw.skip!
        end

        Rails.logger.warn { "Sending request to Wallet Service." }

        wallet_service = WalletService.new(wallet)
        transaction = wallet_service.build_withdrawal!(withdraw)

        Rails.logger.warn { "The currency API accepted withdraw and assigned transaction ID: #{transaction.hash}." }

        Rails.logger.warn { "Updating withdraw state in database." }

        withdraw.txid = transaction.hash
        withdraw.dispatch
        withdraw.save!

        Rails.logger.warn { "OK." }

      rescue Exception => e
        begin
          Rails.logger.error { "Failed to process withdraw. See exception details below." }
          report_exception(e)
          Rails.logger.warn { "Setting withdraw state to failed." }
        ensure
          if withdraw.may_process?
            withdraw.process!
          else
            withdraw.fail!
          end
          Rails.logger.warn { "OK." }
        end
      end
    end
  end
end
