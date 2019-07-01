# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class WithdrawAudit < Base

      self.sleep_time = 5

      def process
        Withdraw.submitted.each do |withdraw|
          withdraw.audit!
        rescue
          puts "Error on withdraw audit: #{$!}"
          puts $!.backtrace.join("\n")
        end
      end
    end
  end
end
