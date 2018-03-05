module Worker
  class DepositCoinAddress
    def process(payload)
      payload.symbolize_keys!

      acc = Account.find_by_id(payload[:account_id])
      return unless acc

      acc.payment_address.tap do |pa|
        pa.with_lock do
          next if pa.address.present?

          pa.update!(CoinAPI[acc.currency].create_address!.slice(:address, :secret))

          Pusher["private-#{acc.member.sn}"].trigger_async \
            :deposit_address,
            type:       'create',
            attributes: pa.as_json
        end
      end
    end
  end
end
