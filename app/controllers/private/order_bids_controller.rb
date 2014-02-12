module Private
  class OrderBidsController < BaseController
    include Concerns::OrderCreation

    def create
      @order = OrderBid.new(order_params(:order_bid))
      order_submit
    end
  end
end
