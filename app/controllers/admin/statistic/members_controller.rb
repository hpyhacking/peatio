module Admin
  module Statistic
    class MembersController < BaseController
      def show
        @members_grid = ::Statistic::MembersGrid.new(params[:statistic_members_grid])
        @assets = @members_grid.assets.page(params[:page]).per(20)
      end
    end
  end
end
