module Jobs
  module Cron
    class Refund
      def self.process
        ::Refund.pending.each do |r|
          r.process!
        rescue StandardError => e
          report_exception_to_screen(e)
          r.fail!
          next
        end
        sleep 60
      end
    end
  end
end
