module Job
  class Coin
    @queue = :coin

    def self.perform(withdraw_id)
      Withdraw.transaction do
        withdraw = Withdraw.lock.find(withdraw_id)

        return unless withdraw.processing?

        withdraw.call_rpc!
      end

      Withdraw.transaction do
        withdraw = Withdraw.lock.find(withdraw_id)

        return unless withdraw.almost_done?

        balance = CoinRPC[withdraw.currency].getbalance.to_d
        raise Account::BalanceError, 'Insufficient coins' if balance < withdraw.amount

        CoinRPC[withdraw.currency].settxfee 0.0005
        tx_id = CoinRPC[withdraw.currency].sendtoaddress withdraw.address, withdraw.amount.to_f

        withdraw.update_column :tx_id, tx_id
        withdraw.succeed!
      end
    end
  end
end
