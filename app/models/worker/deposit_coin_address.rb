module Worker
  class DepositCoinAddress
    def process(payload)
      payload.symbolize_keys!

      payment_address = PaymentAddress.find payload[:payment_address_id]
      return if payment_address.address.present?

      payment_address.update!(CoinAPI[payload[:currency]].create_address!.slice(:address, :secret))

      ::Pusher["private-#{payment_address.account.member.sn}"].trigger_async(
        'deposit_address',
        type: 'create',
        attributes: payment_address.as_json
      )
    end
  end
end
