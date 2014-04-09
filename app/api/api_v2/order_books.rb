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

  end
end
