module Job
  class Coin
    @queue = :coin

    def self.perform(withdraw_id)
      Withdraw.transaction do
        withdraw = Withdraw.lock.find(withdraw_id)

        return unless withdraw.processing?

        withdraw.whodunnit('resque') do
          withdraw.call_rpc!
        end
      end

      Withdraw.transaction do
        withdraw = Withdraw.lock.find(withdraw_id)

        return unless withdraw.almost_done?

        balance = CoinRPC[withdraw.currency].getbalance.to_d
        raise Account::BalanceError, 'Insufficient coins' if balance < withdraw.amount

        CoinRPC[withdraw.currency].settxfee 0.0005
        txid = CoinRPC[withdraw.currency].sendtoaddress withdraw.fund_uid, withdraw.amount.to_f

        withdraw.whodunnit('resque') do
          withdraw.update_column :txid, txid
          withdraw.succeed!
        end
      end
    end
  end
end
