module Admin
  module Statistic
    class MembersController < BaseController
      def show
        @q = Member.order('id desc').includes(:two_factors, :id_document).search(params[:q])
        result = @q.result(distinct: true)
        @result_count = result.size
        @members_count = Member.all.size
        @members = result.page params[:page]

        @register_group = result.where('created_at > ?', 30.days.ago).select('date(created_at) as date, count(id) as total, sum(activated IS TRUE) as total_activated').group('date(created_at)')
      end
    end
  end
end
