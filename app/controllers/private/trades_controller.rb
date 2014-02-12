module Private
  class TradesController < BaseController
    before_filter :authorized, :only => [:ask, :bid]

    def ask
      request_order(@ask_order)
    end

    def bid
      request_order(@bid_order)
    end

    private

    def request_order(order)
      order.assign_attributes(order_params)
      ordering = Ordering.new(order)

      if ordering.submit
        render status: 200, nothing: true
      else
        render status: 500, json: error_result
      end
    end

    def order_params
      params[:order][:state] = Order::WAIT
      params[:order][:bid] = params[:bid]
      params[:order][:ask] = params[:ask]
      params[:order][:member_id] = current_user.id
      params[:order][:origin_volume] = params[:order][:volume]
      params[:order][:currency] = currency
      params.require(:order).permit(:bid, :ask, :currency, :price, :state, :origin_volume, :volume, :member_id)
    end
  end
end
