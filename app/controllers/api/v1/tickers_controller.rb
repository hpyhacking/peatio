module API
  module V1
    class TickersController < BaseController
      def show
        @ticker = Global[params[:id]].ticker
      end
    end
  end
end
