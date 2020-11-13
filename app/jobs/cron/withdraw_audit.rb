module Jobs
  module Cron
    module WithdrawAudit
      def self.process
        Withdraw.accepted.where('updated_at < ?', 30.seconds.ago).each do |withdraw|
          withdraw.process! if withdraw.verify_limits
        end

        sleep 30
      end
    end
  end
end
