module APIv2
  class Orders < Grape::API

    desc 'Get your orders.', {
      params: APIv2::Entities::Order.documentation
    }
    params do
      requires :market, type: String,  values: ::APIv2::Mount::MARKETS
      optional :state,  type: String,  default: 'wait', values: Order.state.values
      optional :limit,  type: Integer, default: 10
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
      requires :id, type: Integer
    end
    get "/order" do
      order = current_user.orders.where(id: params[:id]).first
      present order, with: APIv2::Entities::Order, type: :full
    end

    desc 'Create a Sell/Buy order.'
    params do
      requires :market, type: String, values: ::APIv2::Mount::MARKETS
      requires :side,   type: String, values: %w(sell buy)
      requires :volume, type: String
      requires :price,  type: String
    end
    post "/orders" do
      klass = params[:side] == 'sell' ? OrderAsk : OrderBid
      order = klass.new(
        member_id:     current_user.id,
        ask:           current_market.target_unit,
        bid:           current_market.price_unit,
        state:         ::Order::WAIT,
        source:        'APIv2',
        currency:      params[:market],
        price:         params[:price],
        volume:        params[:volume],
        origin_volume: params[:volume]
      )

      begin
        Ordering.new(order).submit
        present order, with: APIv2::Entities::Order
      rescue
        raise CreateOrderError, $!
      end
    end

    desc 'Cancel an order.'
    params do
      requires :id, type: Integer
    end
    delete "/order" do
      order = current_user.orders.find(params[:id])

      begin
        Ordering.new(order).cancel
        present order, with: APIv2::Entities::Order
      rescue
        raise CancelOrderError, $!
      end
    end

  end
end
