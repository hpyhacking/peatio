# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class Markets < Grape::API

        class OrderBook < Struct.new(:asks, :bids); end

        TradeStruct = Struct.new(:price, :volume, :change)

        helpers API::V2::NamedParams

        resource :markets do
          desc 'Get all available markets.'
          get "/" do
            present ::Market.enabled.ordered, with: API::V2::Entities::Market
          end

          desc 'Get the order book of specified market.'
          params do
            use :market
            optional :asks_limit, type: Integer, default: 20, range: 1..200, desc: 'Limit the number of returned sell orders. Default to 20.'
            optional :bids_limit, type: Integer, default: 20, range: 1..200, desc: 'Limit the number of returned buy orders. Default to 20.'
          end
          get ":market/order-book" do
            asks = OrderAsk.active.with_market(params[:market]).matching_rule.limit(params[:asks_limit])
            bids = OrderBid.active.with_market(params[:market]).matching_rule.limit(params[:bids_limit])
            book = OrderBook.new asks, bids
            present book, with: API::V2::Entities::OrderBook
          end

          desc 'Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.'
          params do
            use :market, :trade_filters
          end
          get ":market/trades" do
            trades = Trade.filter(params[:market], time_to, params[:from], params[:to], params[:limit], order_param)
            present trades, with: API::V2::Entities::Trade
          end

          desc 'Get depth or specified market. Both asks and bids are sorted from highest price to lowest.'
          params do
            use :market
            optional :limit, type: Integer, default: 300, range: 1..1000, desc: 'Limit the number of returned price levels. Default to 300.'
          end
          get ":market/depth" do
            global = Global[params[:market]]
            asks = global.asks[0,params[:limit]].reverse
            bids = global.bids[0,params[:limit]]
            {timestamp: Time.now.to_i, asks: asks, bids: bids}
          end

          desc 'Get OHLC(k line) of specific market.'
          params do
            use :market
            optional :period,    type: Integer, default: 1, values: KLineService::AVAILABLE_POINT_PERIODS, desc: "Time period of K line, default to 1. You can choose between #{KLineService::AVAILABLE_POINT_PERIODS.join(', ')}"
            optional :time_from, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned."
            optional :time_to,   type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data till that time will be returned."
            optional :limit,     type: Integer, default: 30, values: KLineService::AVAILABLE_POINT_LIMITS, desc: "Limit the number of returned data points default to 30. Ignored if time_from and time_to are given."
          end
          get ":market/k-line" do
            KLineService
              .new(params[:market], params[:period])
              .get_ohlc(params.slice(:limit, :time_from, :time_to))
          end

          desc 'Get ticker of all markets.'
          get "/tickers" do
            ::Market.enabled.ordered.inject({}) do |h, m|
              h[m.id] = format_ticker Global[m.id].ticker
              h
            end
          end

          desc 'Get ticker of specific market.'
          params do
            use :market
          end
          get "/:market/tickers/" do
            format_ticker Global[params[:market]].ticker
          end
        end
      end
    end
  end
end
