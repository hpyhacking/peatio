module APIv2
  class OrderBook < Struct.new(:asks, :bids); end

  class OrderBooks < Grape::API

    desc 'Get the order book of specified market.'
    params do
      requires :market, type: String, values: ::APIv2::Mount::MARKETS
      optional :asks_limit, type: Integer, default: 20, range: 1..200
      optional :bids_limit, type: Integer, default: 20, range: 1..200
    end
    get "/order_book" do
      asks = OrderAsk.active.with_currency(params[:market]).matching_rule.limit(params[:asks_limit])
      bids = OrderBid.active.with_currency(params[:market]).matching_rule.limit(params[:bids_limit])
      book = OrderBook.new asks, bids
      present book, with: APIv2::Entities::OrderBook
    end

  end
end
