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
        if withdraw.currency == 'eth'
          balance = open('http://your_geth_server_ip/cgi-bin/total.cgi').read.rstrip.to_f
          raise Account::BalanceError, 'Insufficient coins' if balance < withdraw.sum

          fee = [withdraw.fee.to_f || withdraw.channel.try(:fee) || 0.0005, 0.1].min
          CoinRPC[withdraw.currency].personal_unlockAccount("base_account_address", "", 36000)
          txid = CoinRPC[withdraw.currency].eth_sendTransaction(from: "base_account_address",to: withdraw.fund_uid, value: '0x ' +((withdraw.amount.to_f ).to_i.to_s(16)))
        else
          balance = CoinRPC[withdraw.currency].getbalance.to_d
          raise Account::BalanceError, 'Insufficient coins' if balance < withdraw.sum

          fee = [withdraw.fee.to_f || withdraw.channel.try(:fee) || 0.0005, 0.1].min

          CoinRPC[withdraw.currency].settxfee fee
          txid = CoinRPC[withdraw.currency].sendtoaddress withdraw.fund_uid, withdraw.amount.to_f

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
