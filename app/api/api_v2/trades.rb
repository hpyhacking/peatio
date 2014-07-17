module APIv2
  class Trades < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.'
    params do
      use :market, :trade_filters
    end
    get "/trades" do
      trades = Trade.filter(params[:market], time_to, params[:from], params[:to], params[:limit])
      present trades, with: APIv2::Entities::Trade
    end

    desc 'Get your executed trades. Trades are sorted in reverse creation order.'
    params do
      use :auth, :market, :trade_filters
    end
    get "/trades/my" do
      authenticate!

      trades = Trade.for_member(
        params[:market], current_user,
        limit: params[:limit], time_to: time_to,
        from: params[:from], to: params[:to]
      )

      present trades, with: APIv2::Entities::Trade
    end

  end
end
