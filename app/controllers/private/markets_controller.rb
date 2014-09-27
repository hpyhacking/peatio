module Private
  class MarketsController < BaseController
    skip_before_action :auth_member!, only: [:show]
    after_action :set_default_market

    def show
      @bid = params[:bid]
      @ask = params[:ask]

      @ask_name = I18n.t("currency.name.#{@ask}")
      @bid_name = I18n.t("currency.name.#{@bid}")

      @market = current_market

      @bids   = @market.bids
      @asks   = @market.asks
      @trades = @market.trades

      # default to limit order
      @order_bid = OrderBid.new ord_type: 'limit'
      @order_ask = OrderAsk.new ord_type: 'limit'

      set_member_data if current_user
      gon.jbuilder
    end

    private

    def set_default_market
      cookies[:market_id] = @market.id
    end

    def set_member_data
      @member = current_user

      @member.orders.with_currency(@market).tap do |query|
        @orders_wait = query.with_state(:wait)
        @orders_cancel = query.with_state(:cancel).last(5)
      end

      @trades_done = Trade.for_member(@market.id, current_user, limit: 100, order: 'id desc')
    end

  end
end
