module Admin
  module Statistic
    class OrdersController < BaseController
      def show
        @orders_grid = ::Statistic::OrdersGrid.new(params[:statistic_orders_grid])
        @assets = @orders_grid.assets

        @groups = {
          :count => @assets.size,
          :sum => @assets.sum(:origin_volume),
          :avg => (@assets.average(:price) || 0.to_d).truncate(2),
          :sum_strike => @assets.all.sum do |o|
            o.origin_volume - o.volume
          end
        }
      end
    end
  end
end
