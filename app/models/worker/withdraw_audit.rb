module Worker
  class WithdrawAudit

    def process(payload)
      payload.symbolize_keys!

      Withdraw.transaction do
        withdraw = Withdraw.lock.find payload[:id]

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
