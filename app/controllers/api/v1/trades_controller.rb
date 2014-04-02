module API
  module V1
    class TradesController < BaseController
      def show
        if params[:since]
          @trades = Global[params[:id]].since_trades(params[:since])
        else
          @trades = Global[params[:id]].trades.reverse
        end
      end
    end
  end
end

