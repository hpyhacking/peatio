module Private
  class OrderAsksController < BaseController
    include Concerns::OrderCreation

    def create
      @order = OrderAsk.new(order_params(:order_ask))
      order_submit
    end
  end
end
