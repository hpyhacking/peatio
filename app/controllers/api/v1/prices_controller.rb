module API
  module V1
    class PricesController < BaseController
      def show
        @price = Global[params[:id]].price
      end
    end
  end
end
