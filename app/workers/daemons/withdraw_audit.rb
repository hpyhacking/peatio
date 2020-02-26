# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class WithdrawAudit < Base

      self.sleep_time = 5

      def process
        Withdraw.submitted.where('updated_at < ?', 30.seconds.ago).each do |withdraw|
          withdraw.audit!
        rescue StandardError => e
          raise e if is_db_connection_error?(e)
          report_exception(e)
        end

        Withdraw.to_reject.each do |withdraw|
          withdraw.reject!
        rescue StandardError => e
          raise e if is_db_connection_error?(e)
          report_exception(e)
        end
      end
    end
  end
end
