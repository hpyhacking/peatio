# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class Markets < Grape::API
        helpers ::API::V2::OrderHelpers

        class OrderBook < Struct.new(:asks, :bids); end

        resource :markets do
          desc 'Get all available markets.',
            is_array: true,
            success: API::V2::Entities::Market
          get "/" do
            present ::Market.enabled.ordered, with: API::V2::Entities::Market
          end

          desc 'Get the order book of specified market.',
            is_array: true,
            success: API::V2::Entities::OrderBook
          params do
            requires :market,
                     type: String,
                     values: { value: -> { ::Market.enabled.ids }, message: 'public.market.doesnt_exist' },
                     desc: -> { V2::Entities::Market.documentation[:id] }
            optional :asks_limit,
                     type: { value: Integer, message: 'public.order_book.non_integer_ask_limit' },
                     values: { value: 1..200, message: 'public.order_book.invalid_ask_limit' },
                     default: 20,
                     desc: 'Limit the number of returned sell orders. Default to 20.'
            optional :bids_limit,
                     type: { value: Integer, message: 'public.order_book.non_integer_bid_limit' },
                     values: { value: 1..200, message: 'public.order_book.invalid_bid_limit' },
                     default: 20,
                     desc: 'Limit the number of returned buy orders. Default to 20.'
          end
          get ":market/order-book" do
            asks = OrderAsk.active.with_market(params[:market]).matching_rule.limit(params[:asks_limit])
            bids = OrderBid.active.with_market(params[:market]).matching_rule.limit(params[:bids_limit])
            book = OrderBook.new asks, bids
            present book, with: API::V2::Entities::OrderBook
          end

          desc 'Get recent trades on market, each trade is included only once. Trades are sorted in reverse creation order.',
            is_array: true,
            success: API::V2::Entities::Trade
          params do
            requires :market,
                     type: String,
                     values: { value: -> { ::Market.enabled.ids }, message: 'public.market.doesnt_exist' },
                     desc: -> { V2::Entities::Market.documentation[:id] }
            optional :limit,
                     type: { value: Integer, message: 'public.trade.non_integer_limit' },
                     values: { value: 1..1000, message: 'public.trade.invalid_limit' },
                     default: 100,
                     desc: 'Limit the number of returned trades. Default to 100.'
            optional :page,
                     type: { value: Integer, message: 'public.trade.non_integer_page' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'public.trade.non_positive_page'},
                     default: 1,
                     desc: 'Specify the page of paginated results.'
            optional :timestamp,
                     type: { value: Integer, message: 'public.trade.non_integer_timestamp' },
                     desc: "An integer represents the seconds elapsed since Unix epoch."\
                       "If set, only trades executed before the time will be returned."
            optional :order_by,
                     type: String,
                     values: { value: %w(asc desc), message: 'public.trade.invalid_order_by' },
                     default: 'desc',
                     desc: "If set, returned trades will be sorted in specific order, default to 'desc'."
          end
          get ":market/trades" do
            Trade.order(order_param)
                 .tap { |q| q.where!(market: params[:market]) if params[:market] }
                 .tap { |q| present paginate(q), with: API::V2::Entities::Trade }
          end

          desc 'Get depth or specified market. Both asks and bids are sorted from highest price to lowest.'
          params do
            requires :market,
                     type: String,
                     values: { value: -> { ::Market.enabled.ids }, message: 'public.market.doesnt_exist' },
                     desc: -> { V2::Entities::Market.documentation[:id] }
            optional :limit,
                     type: { value: Integer, message: 'public.market_depth.non_integer_limit' },
                     values: { value: 1..1000, message: 'public.market_depth.invalid_limit' },
                     default: 300,
                     desc: 'Limit the number of returned price levels. Default to 300.'
          end
          get ":market/depth" do
            global = Global[params[:market]]
            asks = global.asks[0,params[:limit]].reverse
            bids = global.bids[0,params[:limit]]
            { timestamp: Time.now.to_i, asks: asks, bids: bids }
          end

          desc 'Get OHLC(k line) of specific market.'
          params do
            requires :market,
                     type: String,
                     values: { value: -> { ::Market.enabled.ids }, message: 'public.market.doesnt_exist' },
                     desc: -> { V2::Entities::Market.documentation[:id] }
            optional :period,
                     type: { value: Integer, message: 'public.k_line.non_integer_period' },
                     values: { value: KLineService::AVAILABLE_POINT_PERIODS, message: 'public.k_line.invalid_period' },
                     default: 1,
                     desc: "Time period of K line, default to 1. You can choose between #{KLineService::AVAILABLE_POINT_PERIODS.join(', ')}"
            optional :time_from,
                     type: { value: Integer, message: 'public.k_line.non_integer_time_from' },
                     allow_blank: { value: false, c_name: 'k_line' },
                     desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned."
            optional :time_to,
                     type: { value: Integer, message: 'public.k_line.non_integer_time_to' },
                     allow_blank: { value: false, c_name: 'k_line' },
                     desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data till that time will be returned."
            optional :limit,
                     type: { value: Integer, message: 'public.k_line.non_integer_limit' },
                     values: { value: KLineService::AVAILABLE_POINT_LIMITS, message: 'public.k_line.invalid_limit' },
                     default: 30,
                     desc: "Limit the number of returned data points default to 30. Ignored if time_from and time_to are given."
          end
          get ":market/k-line" do
            KLineService
              .new(params[:market], params[:period])
              .get_ohlc(params.slice(:limit, :time_from, :time_to))
          end

          desc 'Get ticker of all markets (For response doc see /:market/tickers/ response).'
          get "/tickers" do
            ::Market.enabled.ordered.inject({}) do |h, m|
              h[m.id] = format_ticker Global[m.id].ticker
              h
            end
          end

          desc 'Get ticker of specific market.',
               success: API::V2::Entities::Ticker
          params do
            requires :market,
                     type: String,
                     values: { value: -> { ::Market.enabled.ids }, message: 'public.market.doesnt_exist' },
                     desc: -> { V2::Entities::Market.documentation[:id] }
          end
          get "/:market/tickers/" do
            present format_ticker(Global[params[:market]].ticker),
                    with: API::V2::Entities::Ticker
          end
        end
      end
    end
  end
end
