module APIv2
  class Orders < Grape::API

    before { authenticate! }

    desc 'Get your orders.'
    params do
      requires :market, type: String,  values: Market.all.map(&:id)
      optional :state,  type: String,  default: 'wait', values: Order.state.values
      optional :limit,  type: Integer, default: 10
    end
    get "/orders" do
      market = Market.find params[:market]
      orders = current_user.orders
        .with_currency(market)
        .with_state(params[:state])
        .limit(params[:limit])
    end

  end
end
