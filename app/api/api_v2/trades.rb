# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Trades < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.'
    params do
      use :market, :trade_filters
    end
    get "/trades" do
      trades = Trade.filter(params[:market], time_to, params[:from], params[:to], params[:limit], order_param)
      present trades, with: APIv2::Entities::Trade
    end

    desc 'Get your executed trades. Trades are sorted in reverse creation order.', scopes: %w(history)
    params do
      use :market, :trade_filters
    end
    get "/trades/my" do
      authenticate!
      trading_must_be_permitted!

      trades = Trade.for_member(
        params[:market], current_user,
        limit: params[:limit], time_to: time_to,
        from: params[:from], to: params[:to],
        order: order_param
      )

      present trades, with: APIv2::Entities::Trade, current_user: current_user
    end

  end
end
