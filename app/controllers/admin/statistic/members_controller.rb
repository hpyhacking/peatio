module Admin
  module Statistic
    class MembersController < BaseController
      def show
        @q = Member.order('id desc').includes(:two_factor, :id_document).search(params[:q])
        result = @q.result(distinct: true)
        @result_count = result.size
        @members_count = Member.all.size
        @members = result.page params[:page]
      end
    end
  end
end
