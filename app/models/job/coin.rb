module Job
  class Coin
    @queue = :coin

    def self.perform(withdraw_id)
      withdraw = Withdraw.find(withdraw_id)

      amount = withdraw.amount
      balance = CoinRPC[withdraw.currency].getbalance.to_d

      raise Account::BalanceError, 'Insufficient coins' if balance < amount

      CoinRPC[withdraw.currency].settxfee 0.0005
      tx_id = CoinRPC[withdraw.currency].sendtoaddress withdraw.address, withdraw.amount.to_f

      withdraw.update_column :tx_id, tx_id
    end
  end
end
