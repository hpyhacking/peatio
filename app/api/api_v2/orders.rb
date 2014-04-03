module APIv2
  class Orders < Grape::API

    format :json
    default_format :json

    helpers Helpers

    desc 'Get user orders'
    get "/orders" do
      market = Market.find params[:market]
      orders = current_user.orders
      .with_currency(market)
      .with_state(params[:state])
      .limit(params[:limit])
    end

  end
end
