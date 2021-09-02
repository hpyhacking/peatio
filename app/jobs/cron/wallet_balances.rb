module Jobs
  module Cron
    module WalletBalances
      def self.process
        Wallet.active_retired.find_each do |w|
          w.update!(balance: w.current_balance)
        rescue StandardError => e
          report_exception_to_screen(e)
          next
        end
        sleep 60
      end
    end
  end
end
