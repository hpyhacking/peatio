module Worker
  class WithdrawCoin
    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      Withdraw.transaction do
        withdraw = Withdraw.lock.find payload[:id]

        return unless withdraw.processing?

        withdraw.whodunnit('Worker::WithdrawCoin') do
          withdraw.call_rpc
          withdraw.save!
        end
      end

      Withdraw.transaction do
        withdraw = Withdraw.lock.find payload[:id]

        return unless withdraw.almost_done?

        if withdraw.currency.to_sym == :xrp
          txid = CoinRPC[withdraw.currency.to_sym].sendtoaddress(
            withdraw.fund_uid,
            withdraw.amount.to_f,
            fee
          )
        else
          balance = CoinRPC[withdraw.currency.to_sym].getbalance.to_d
          raise Account::BalanceError, 'Insufficient coins' if balance < withdraw.sum

          fee = [withdraw.fee.to_f || withdraw.channel.try(:fee) || 0.0005, 0.1].min

          CoinRPC[withdraw.currency.to_sym].settxfee(fee)
          txid = CoinRPC[withdraw.currency.to_sym].sendtoaddress(withdraw.fund_uid, withdraw.amount.to_f)
        end

        withdraw.whodunnit('Worker::WithdrawCoin') do
          withdraw.update_column :txid, txid

          # withdraw.succeed! will start another transaction, cause
          # Account after_commit callbacks not to fire
          withdraw.succeed
          withdraw.save!
        end
      end
    end
  end
end
