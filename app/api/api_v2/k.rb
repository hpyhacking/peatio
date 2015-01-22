module APIv2
  class K < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get OHLC(k line) of specific market.'
    params do
      use :market
      optional :limit,     type: Integer, default: 30, values: 1..10000, desc: "Limit the number of returned data points, default to 30."
      optional :period,    type: Integer, default: 1, values: [1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080], desc: "Time period of K line, default to 1. You can choose between 1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080"
      optional :timestamp, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned."
    end
    get "/k" do
      get_k_json
    end

    desc "Get K data with pending trades, which are the trades not included in K data yet, because there's delay between trade generated and processed by K data generator."
    params do
      use :market
      requires :trade_id,  type: Integer, desc: "The trade id of the first trade you received."
      optional :limit,     type: Integer, default: 30, values: 1..10000, desc: "Limit the number of returned data points, default to 30."
      optional :period,    type: Integer, default: 1, values: [1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080], desc: "Time period of K line, default to 1. You can choose between 1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080"
      optional :timestamp, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only k-line data after that time will be returned."
    end
    get "/k_with_pending_trades" do
      k = get_k_json

      if params[:trade_id] > 0
        from = Time.at k.last[0]
        trades = Trade.with_currency(params[:market])
          .where('created_at >= ? AND id < ?', from, params[:trade_id])
          .map(&:for_global)

        {k: k, trades: trades}
      else
        {k: k, trades: []}
      end
    end

  end
end
