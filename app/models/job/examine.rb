module Job
  class Examine
    @queue = :examine

    def self.perform(withdraw_id)
      Withdraw.transaction do
        withdraw = Withdraw.lock.find(withdraw_id)

        return unless withdraw.submitted?

        if withdraw.account.examine
          withdraw.accept!
        else
          withdraw.mark_suspect!
        end
      end
    end
  end
end
