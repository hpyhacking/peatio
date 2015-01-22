module APIv2
  class OrderBook < Struct.new(:asks, :bids); end

  class OrderBooks < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get the order book of specified market.'
    params do
      use :market
      optional :asks_limit, type: Integer, default: 20, range: 1..200, desc: 'Limit the number of returned sell orders. Default to 20.'
      optional :bids_limit, type: Integer, default: 20, range: 1..200, desc: 'Limit the number of returned buy orders. Default to 20.'
    end
    get "/order_book" do
      asks = OrderAsk.active.with_currency(params[:market]).matching_rule.limit(params[:asks_limit])
      bids = OrderBid.active.with_currency(params[:market]).matching_rule.limit(params[:bids_limit])
      book = OrderBook.new asks, bids
      present book, with: APIv2::Entities::OrderBook
    end

    desc 'Get depth or specified market. Both asks and bids are sorted from highest price to lowest.'
    params do
      use :market
      optional :limit, type: Integer, default: 300, range: 1..1000, desc: 'Limit the number of returned price levels. Default to 300.'
    end
    get "/depth" do
      global = Global[params[:market]]
      asks = global.asks[0,params[:limit]].reverse
      bids = global.bids[0,params[:limit]]
      {timestamp: Time.now.to_i, asks: asks, bids: bids}
    end

  end
end
