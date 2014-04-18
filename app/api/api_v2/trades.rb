module APIv2
  class Trades < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get recent trades on market.'
    params do
      use :market, :trade_filters
    end
    get "/trades" do
      trades = Trade.with_currency(params[:market]).order('id desc').limit(params[:limit])
      trades = trades.where('created_at >= ?', time_from) if time_from

      present trades, with: APIv2::Entities::Trade
    end

    desc 'Get your executed trades.'
    params do
      use :auth, :market, :trade_filters
    end
    get "/trades/my" do
      authenticate!

      trades = Trade.for_member(
        params[:market], current_user,
        limit: params[:limit], from: time_from
      )

      present trades, with: APIv2::Entities::Trade
    end

  end
end
