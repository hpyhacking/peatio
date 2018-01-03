module Worker
  class DepositCoinAddress
    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      payment_address = PaymentAddress.find payload[:payment_address_id]
      return if payment_address.address.present?

      currency = payload[:currency]
      address  = CoinRPC[currency].getnewaddress('payment')

      return unless payment_address.update(currency == 'xrp' ? address : { address: address })

      ::Pusher["private-#{payment_address.account.member.sn}"].trigger_async(
        'deposit_address',
        type: 'create',
        attributes: payment_address.as_json
      )
    end
  end
end
