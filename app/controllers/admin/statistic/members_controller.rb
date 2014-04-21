module Admin
  module Statistic
    class MembersController < BaseController
      def show
        @q = Member.order('id desc').includes(:two_factor, :id_document).search(params[:q])
        @members = @q.result(distinct: true).page params[:page]
      end
    end
  end
end
