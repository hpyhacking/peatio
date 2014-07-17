module Private
  class MarketsController < BaseController
    after_filter :set_default_market

    layout 'market'

    def show
      @bid = params[:bid]
      @ask = params[:ask]

      @ask_name = I18n.t("currency.name.#{@ask}")
      @bid_name = I18n.t("currency.name.#{@bid}")

      @market = current_market

      @bids   = Global[@market].bids
      @asks   = Global[@market].asks
      @trades = Global[@market].trades
      @price  = Global[@market].price
      @ticker = Global[@market].ticker

      # default to limit order
      @order_bid = OrderBid.new ord_type: 'limit'
      @order_ask = OrderAsk.new ord_type: 'limit'

      @member = current_user

      @member.orders.with_currency(@market).tap do |query|
        @orders_wait = query.with_state(:wait)
        @orders_cancel = query.with_state(:cancel).last(5)
      end

      @trades_done = Trade.for_member(@market.id, current_user, limit: 100)

      gon.jbuilder
    end

    private

    def set_default_market
      cookies[:market_id] = @market.id
    end

  end
end
