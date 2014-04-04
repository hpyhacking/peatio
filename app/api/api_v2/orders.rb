module APIv2
  class Orders < Grape::API

    MARKETS = Market.all.map(&:id)

    desc 'Get your orders.', {
      params: APIv2::Entities::Order.documentation
    }
    params do
      requires :market, type: String,  values: MARKETS
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
      present order, with: APIv2::Entities::Order
    end

  end
end
