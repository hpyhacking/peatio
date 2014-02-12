module Job
  class Coin
    @queue = :coin
    
    def self.perform(withdraw_id)
      ActiveRecord::Base.transaction do
        withdraw = Withdraw.find(withdraw_id).lock!
        raise :unknown_state unless withdraw.state.coin_ready?

        amount = withdraw.amount
        balance = CoinRPC[withdraw.currency].getbalance.to_d

        if balance >= amount
          withdraw.update_attribute(:state, :coin_done)
        end
      end

      ActiveRecord::Base.transaction do
        withdraw = Withdraw.find(withdraw_id).lock!
        raise :unknown_state unless withdraw.state.coin_done?
        CoinRPC[withdraw.currency].settxfee 0.0005
        tx_id = CoinRPC[withdraw.currency].sendtoaddress withdraw.address, withdraw.amount.to_f
        withdraw.update_attributes(tx_id: tx_id, state: :done)
      end
    end
  end
end

