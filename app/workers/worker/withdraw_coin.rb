# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class WithdrawCoin
    def process(payload)
      payload.symbolize_keys!

      Rails.logger.warn { ">>>>> Received request for processing withdraw ##{payload[:id]}." }

      withdraw = Withdraw.find_by_id(payload[:id])

      unless withdraw
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

        api     = withdraw.currency.api
        balance = api.load_balance!

        if balance < withdraw.sum
          Rails.logger.warn { "The withdraw failed because wallet balance is not sufficient (wallet balance is #{balance.to_s("F")})." }
          withdraw.suspect!
          return
        end

        pa = withdraw.account.payment_address

        Rails.logger.warn { "Sending request to currency API." }

        txid = api.create_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: withdraw.rid },
          withdraw.amount.to_d
        )
        Rails.logger.warn { "The currency API accepted withdraw and assigned transaction ID: #{txid}." }

        Rails.logger.warn { "Updating withdraw state in database." }

        withdraw.whodunnit self.class.name do
          withdraw.txid = txid
          withdraw.success
          withdraw.save!
        end

        Rails.logger.warn { "OK." }

      rescue Exception => e
        begin
          Rails.logger.error { "Failed to process withdraw. See exception details below." }
          report_exception(e)
          Rails.logger.warn { "Setting withdraw state to failed." }
        ensure
          withdraw.fail!
          Rails.logger.warn { "OK." }
        end
      end
    end
  end
end
