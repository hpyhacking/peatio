module Admin
  module Statistic
    class WithdrawsController < BaseController
      def show
        @withdraws_grid = ::Statistic::WithdrawsGrid.new(params[:statistic_withdraws_grid])
        @assets = @withdraws_grid.assets

        @groups = {
          :count => @assets.all.size,
          :amount => @assets.sum(:amount),
          :fee => @assets.sum(:fee)
        }
      end
    end
  end
end
