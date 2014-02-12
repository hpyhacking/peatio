module Job
  class Examine
    @queue = :examine
    
    def self.perform(withdraw_id)
      withdraw = Withdraw.find(withdraw_id)
      return unless withdraw.state.wait?
      
      ActiveRecord::Base.transaction do
        withdraw = Withdraw.find(withdraw_id).lock!
        return unless withdraw.state.wait?

        if withdraw.account.examine
          withdraw.update_attribute(:state, :examined)
        else
          withdraw.update_attribute(:state, :examined_warning)
        end
      end
    end
  end
end
