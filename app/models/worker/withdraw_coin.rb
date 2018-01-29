module Worker
  class WithdrawCoin
    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      Withdraw.transaction do
        withdraw = Withdraw.lock.find payload[:id]

        return unless withdraw.processing?

        withdraw.whodunnit 'Worker::WithdrawCoin' do
          withdraw.call_rpc
          withdraw.save!
        end
      end

      Withdraw.transaction do
        withdraw = Withdraw.lock.find payload[:id]

        return unless withdraw.almost_done?

        balance = CoinAPI[withdraw.currency.to_sym].load_balance!
        raise Account::BalanceError, 'Insufficient coins' if balance < withdraw.sum

        fee = [withdraw.fee.to_f || withdraw.channel.try(:fee) || 0.0005, 0.1].min

        pa = withdraw.account.payment_address

        txid = CoinAPI[withdraw.currency.to_sym].create_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: withdraw.fund_uid },
          withdraw.amount.to_d,
          fee.to_d
        )

        withdraw.whodunnit 'Worker::WithdrawCoin' do
          withdraw.update_columns(txid: txid, done_at: Time.current)

          # withdraw.succeed! will start another transaction, cause
          # Account after_commit callbacks not to fire
          withdraw.succeed
          withdraw.save!
        end
      end
    end
  end
end
