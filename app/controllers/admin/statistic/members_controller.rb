module Admin
  module Statistic
    class MembersController < BaseController
      def show
        @members_count = Member.count
        @register_group = Member.where('created_at > ?', 30.days.ago).select('date(created_at) as date, count(id) as total, sum(activated IS TRUE) as total_activated').group('date(created_at)')
      end
    end
  end
end
