module Worker
  class DepositCoin

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      sleep 0.5 # nothing result without sleep by query gettransaction api

      channel_key = payload[:channel_key]
      txid = payload[:txid]

      channel = DepositChannel.find_by_key(channel_key)
      raw     = channel.currency_obj.api.gettransaction(txid)
      detail  = raw[:details].first.symbolize_keys!
      return if detail[:account] != "payment" || detail[:category] != "receive"

      ActiveRecord::Base.transaction do
        return if PaymentTransaction.find_by_txid(txid)

        tx = PaymentTransaction.create! \
          txid: txid,
          address: detail[:address],
          amount: detail[:amount].to_s.to_d,
          confirmations: raw[:confirmations],
          receive_at: Time.at(raw[:timereceived]).to_datetime,
          currency: channel.currency

        deposit = channel.kls.create! \
          txid: tx.txid,
          amount: tx.amount,
          member: tx.member,
          account: tx.account,
          currency: tx.currency,
          memo: tx.confirmations

        deposit.submit!
      end
    end
  end
end
