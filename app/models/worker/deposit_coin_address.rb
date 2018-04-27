module Worker
  class DepositCoinAddress
    def process(payload)
      payload.symbolize_keys!

      acc = Account.find_by_id(payload[:account_id])
      return unless acc
      return unless acc.currency.coin?

      acc.payment_address.tap do |pa|
        pa.with_lock do
          next if pa.address.present?

          # Supply address ID in case of BitGo address generation if it exists.
          result = acc.currency.api.create_address!(address_id: pa.details['bitgo_address_id'])

          # Save all the details including address ID from BitGo to use it later.
          pa.update! \
            result.extract!(:address, :secret).merge!(details: pa.details.merge(result))

          # Enqueue address generation again if address is not provided.
          pa.enqueue_address_generation if pa.address.blank?

          pusher_event(acc, pa) unless pa.address.blank?
        end
      end
    end

  private

    def pusher_event(acc, pa)
      Pusher["private-#{acc.member.sn}"].trigger_async \
        :deposit_address,
        type:       'create',
        attributes: pa.as_json
    end
  end
end
