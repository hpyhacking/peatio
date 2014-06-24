module APIv2
  class Orders < Grape::API
    helpers ::APIv2::NamedParams

    before { authenticate! }

    desc 'Get your orders.'
    params do
      use :auth, :market
      optional :state,  type: String,  default: 'wait', values: Order.state.values, desc: "Filter order by state, default to 'wait' (active orders)."
      optional :limit,  type: Integer, default: 10, range: 1..1000, desc: "Limit the number of returned orders, default to 10."
    end
    get "/orders" do
      orders = current_user.orders
        .with_currency(current_market)
        .with_state(params[:state])
        .limit(params[:limit])

      present orders, with: APIv2::Entities::Order
    end

    desc 'Get information of specified order.'
    params do
      use :auth, :order_id
    end
    get "/order" do
      order = current_user.orders.where(id: params[:id]).first
      present order, with: APIv2::Entities::Order, type: :full
    end

    desc 'Create multiple sell/buy orders.'
    params do
      use :auth, :market
      requires :orders, type: Array do
        use :order
      end
    end
    post "/orders/multi" do
      Order.transaction do
        orders = params[:orders].map {|attrs| create_order(attrs) }
        present orders, with: APIv2::Entities::Order
      end
    end

    desc 'Create a Sell/Buy order.'
    params do
      use :auth, :market, :order
    end
    post "/orders" do
      order = create_order params
      present order, with: APIv2::Entities::Order
    end

    desc 'Cancel an order.'
    params do
      use :auth, :order_id
    end
    post "/order/delete" do
      begin
        order = current_user.orders.find(params[:id])
        Ordering.new(order).cancel
        present order, with: APIv2::Entities::Order
      rescue
        raise CancelOrderError, $!
      end
    end

    desc 'Cancel all my orders.'
    params do
      use :auth
    end
    post "/orders/clear" do
      begin
        orders = current_user.orders.with_state(:wait)
        orders.each {|o| Ordering.new(o).cancel }
        present orders, with: APIv2::Entities::Order
      rescue
        raise CancelOrderError, $!
      end
    end

  end
end
