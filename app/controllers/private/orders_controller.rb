module Private
  class OrdersController < BaseController

    def destroy
      ActiveRecord::Base.transaction do
        order = current_user.orders.find(params[:id])
        ordering = Ordering.new(order)

        if ordering.cancel
          render status: 200, nothing: true
        else
          render status: 500, nothing: true
        end
      end
    end

    def clear
      @orders = current_user.orders.with_currency(current_market).with_state(:wait)
      Ordering.new(@orders).cancel
      render status: 200, nothing: true
    end

  end
end
