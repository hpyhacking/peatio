# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class K < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get OHLC(k line) of specific market.'
    params do
      use :market
      optional :period,    type: Integer, default: 1, values: KLineService::AVAILABLE_POINT_PERIODS, desc: "Time period of K line, default to 1. You can choose between #{KLineService::AVAILABLE_POINT_PERIODS.join(', ')}"
      optional :time_from, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned."
      optional :time_to,   type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data till that time will be returned."
      optional :limit,     type: Integer, default: 30, values: KLineService::AVAILABLE_POINT_LIMITS, desc: "Limit the number of returned data points default to 30. Ignored if time_from and time_to are given."
    end
    get "/k" do
      KLineService
        .new(params[:market], params[:period])
        .get_ohlc(params.slice(:limit, :time_from, :time_to))
    end

    desc "Get K data with pending trades, which are the trades not included in K data yet, because there's delay between trade generated and processed by K data generator.",
       deprecated: true
    params do
      use :market
      requires :trade_id,  type: Integer, desc: "The trade id of the first trade you received."
      optional :period,    type: Integer, default: 1, values: KLineService::AVAILABLE_POINT_PERIODS, desc: "Time period of K line, default to 1. You can choose between #{KLineService::AVAILABLE_POINT_PERIODS.join(', ')}"
      optional :time_from, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned."
      optional :time_to, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data till that time will be returned."
      optional :limit,     type: Integer, default: 30, values: KLineService::AVAILABLE_POINT_LIMITS, desc: "Limit the number of returned data points, default to 30."
    end
    get "/k_with_pending_trades" do
      k = KLineService
            .new(params[:market], params[:period])
            .get_ohlc(params.slice(:limit, :time_from, :time_to))

      if params[:trade_id] > 0 && k.present?
        from   = Time.at k.last[0]
        trades = Trade.with_market(params[:market])
                      .where('created_at >= ? AND id < ?', from, params[:trade_id])
                      .map(&:for_global)

        { k: k, trades: trades }
      else
        { k: k, trades: [] }
      end
    end

  end
end
