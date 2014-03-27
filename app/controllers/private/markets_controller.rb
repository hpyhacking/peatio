module Private
  class MarketsController < BaseController
    after_filter :set_default_market

    def show
      @bid = params[:bid]
      @ask = params[:ask]

      @ask_name = I18n.t("currency.name.#{@ask}")
      @bid_name = I18n.t("currency.name.#{@bid}")

      @market = Market.find(params[:market])

      @bids   = Global[@market].bids
      @asks   = Global[@market].asks
      @trades = Global[@market].trades
      @price  = Global[@market].price

      @order_bid = OrderBid.empty
      @order_ask = OrderAsk.empty

      @member = current_user

      @member.orders.with_currency(@market).tap do |query|
        @orders_wait = query.with_state(:wait)
        @orders_done = query.with_state(:done).last(5)
        @orders_cancel = query.with_state(:cancel).last(5)
      end

      gon.jbuilder
    end

    private
    def set_default_market
      cookies[:market] = params[:market]
    end
  end
end
