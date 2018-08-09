# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class DepositCoinAddress
    def process(payload)
      payload.symbolize_keys!

      acc = Account.find_by_id(payload[:account_id])
      return unless acc
      return unless acc.currency.coin?

      wallet = Wallet.active.deposit.find_by(currency_id: acc.currency_id)
      return unless wallet

      wallet_service = WalletService[wallet]

      acc.payment_address.tap do |pa|
        pa.with_lock do
          next if pa.address.present?

          # Supply address ID in case of BitGo address generation if it exists.
          result = wallet_service.create_address \
            address_id: pa.details['bitgo_address_id'],
            label:      acc.member.uid
          # Save all the details including address ID from BitGo to use it later.
          pa.update! \
            result.extract!(:address, :secret).merge!(details: pa.details.merge(result))
        end

        # Enqueue address generation again if address is not provided.
        pa.enqueue_address_generation if pa.address.blank?

        trigger_pusher_event(acc, pa) unless pa.address.blank?
      end

    # Don't re-enqueue this job in case of error.
    # The system is designed in such way that when user will
    # request list of accounts system will ask to generate address again (if it is not generated of course).
    rescue => e
      report_exception(e)
    end

  private

    def trigger_pusher_event(acc, pa)
      Member.trigger_pusher_event acc.member_id, :deposit_address, type: :create, attributes: {
        currency: pa.currency.code,
        address:  pa.address
      }
    end
  end
end
