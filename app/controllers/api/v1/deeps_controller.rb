module API
  module V1
    class DeepsController < BaseController
      def show
        @asks = Global[params[:id]].asks
        @bids = Global[params[:id]].bids
      end
    end
  end
end

