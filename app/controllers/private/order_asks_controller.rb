module Private
  class OrderAsksController < BaseController
    include Concerns::OrderCreation

    def create
      @order = OrderAsk.new(order_params(:order_ask))
      order_submit
    end

    def clear
      @orders = OrderAsk.where(member_id: current_user.id).with_state(:wait)
      @orders.each {|o| Ordering.new(o).cancel }
      render status: 200, nothing: true
    end

  end
end
