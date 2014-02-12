module Admin
  module Statistic
    class TradesController < BaseController
      def show
        @trades_grid = ::Statistic::TradesGrid.new(params[:statistic_trades_grid])
        @assets = @trades_grid.assets

        @groups = {
          :volume => @assets.sum(:volume),
          :amount => @assets.sum {|t| t.price * t.volume},
          :avg_price => @assets.average(:price),
          :max_price => @assets.maximum(:price),
          :min_price => @assets.minimum(:price)
        }

        @groups.merge!({
          :volume_fee => (@groups[:volume]),
          :amount_fee => (@groups[:amount]),
          :count => @assets.all.size
        })
      end
    end
  end
end
