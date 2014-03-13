module Job
  class Examine
    @queue = :examine

    def self.perform(withdraw_id)
      withdraw = Withdraw.find(withdraw_id)

      return unless withdraw.submitted?

      if withdraw.account.examine
        withdraw.accept!
      else
        withdraw.mark_suspect!
      end
    end
  end
end
