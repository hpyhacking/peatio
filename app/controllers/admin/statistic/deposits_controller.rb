module Admin
  module Statistic
    class DepositsController < BaseController
      prepend_before_filter :load_grid

      def show
        @groups = {
          :count => @assets.all.size,
          :amount => @assets.sum(:amount)
        }
      end

      private
      def load_grid
        @deposits_grid = ::Statistic::DepositsGrid.new(params[:statistic_deposits_grid])
        @assets = @deposits_grid.assets
      end
    end
  end
end
