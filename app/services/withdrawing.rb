class Withdrawing
  def initialize(withdraw)
    @withdraw = withdraw
  end

  def request
    @withdraw.invalid? and return false

    ActiveRecord::Base.transaction do
      account = Account.find(@withdraw.account_id).lock!

      if @withdraw.save
        withdraw = @withdraw.lock!

        account.lock_funds \
          withdraw.sum, 
          reason: Account::WITHDRAW_LOCK, 
          ref: withdraw
      else
        return false
      end
    end
  end

  def cancel
    ActiveRecord::Base.transaction do
      withdraw = @withdraw.lock!
      account = @withdraw.account.lock!

      if withdraw.state.apply?
        withdraw.update_attribute(:state, :cancel)

        account.unlock_funds \
          withdraw.sum,
          reason: Account::WITHDRAW_UNLOCK,
          ref: withdraw
      end
    end
  end

  def transact
    if @withdraw.state.examined? or @withdraw.state.transact?
      ActiveRecord::Base.transaction do
        withdraw = @withdraw.lock!
        account = @withdraw.account.lock!

        if withdraw.state.examined?
          withdraw.update_attribute(:state, :transact)

          account.unlock_and_sub_funds \
            withdraw.sum, locked: withdraw.sum, fee: withdraw.fee,
            reason: Account::WITHDRAW, ref: withdraw
        end
      end

      ActiveRecord::Base.transaction do
        withdraw = @withdraw.lock!
        if withdraw.state.transact? 
          if withdraw.coin?
            withdraw.update_attribute(:state, :coin_ready)
          else
            withdraw.update_attributes(state: :done, tx_id: withdraw.sn)
          end
        end
      end
    elsif @withdraw.state.wait?
      @withdraw.examine
    end
  end

  def reject
    ActiveRecord::Base.transaction do
      withdraw = @withdraw.lock!
      account = @withdraw.account.lock!

      if withdraw.state.examined? or withdraw.state.apply?
        withdraw.update_attribute(:state, :reject)

        account.unlock_funds \
          withdraw.sum,
          reason: Account::WITHDRAW_UNLOCK,
          ref: withdraw
      end
    end
  end
end
