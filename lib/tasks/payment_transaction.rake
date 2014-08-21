namespace :payment_transaction do
  desc "deposit multi payment"
  task to_many_user: :environment do
    txid = ENV['txid']
    channel_key = ENV['channel_key'] || 'satoshi'
    channel = DepositChannel.find_by_key(channel_key)
    raw     = channel.currency_obj.api.gettransaction(txid)

    pt = PaymentTransaction.find_by_txid(txid)
    raise 'error txid' unless pt

    ActiveRecord::Base.transaction do
      raw[:details].each do |detail|
        detail.symbolize_keys!

        next if pt.address == detail[:address]

        if detail[:account] != "payment" || detail[:category] != "receive"
          raise 'error detail'
        end

        account = PaymentAddress.find_by_address(detail[:address]).account
        raise 'error account' unless account

        member = account.member

        deposit = channel.kls.create! \
          txid: txid,
          member: member,
          account: account,
          currency: channel.currency,
          amount: detail[:amount].to_s.to_d,
          memo: channel[:max_confirm]

        deposit.submit!
        deposit.accept!
      end
    end
  end
end
