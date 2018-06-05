# encoding: UTF-8
# frozen_string_literal: true

module Private
  class MarketsController < BaseController
    include Concerns::DisableMarketsUI
    include CurrencyHelper

    skip_before_action :auth_member!, only: [:show]
    before_action :enabled_market?
    after_action :set_default_market

    layout false

    def show
      @bid = params[:bid]
      @ask = params[:ask]

      @market        = current_market
      @markets       = Market.enabled.ordered
      @market_groups = @markets.map(&:ask_unit).uniq

      @bids   = @market.bids
      @asks   = @market.asks
      @trades = @market.trades

      # default to limit order
      @order_bid = OrderBid.new(ord_type: 'limit')
      @order_ask = OrderAsk.new(ord_type: 'limit')

      set_member_data if current_user
      gon.jbuilder
      render json: trading_ui_variables
    end

    private

    def enabled_market?
      redirect_to trading_path(Market.enabled.ordered.first) unless current_market.enabled?
    end

    def set_default_market
      cookies[:market_id] = @market.id
    end

    def set_member_data
      @member = current_user
      @orders_wait = @member.orders.includes(:market).where(market_id: @market).with_state(:wait)
      @trades_done = Trade.includes(:market).for_member(@market.id, current_user, limit: 100, order: 'id desc')
    end

    def trading_ui_variables
      accounts = @member&.accounts&.enabled&.includes(:currency)&.map do |x|
        { id:         x.id,
          locked:     x.locked,
          amount:     x.amount,
          currency:   {
            code:     x.currency.code,
            symbol:   x.currency.symbol,
            type:     x.currency.type,
            icon_url: currency_icon_url(x.currency) } }
      end

      { current_market: @market.as_json,
        gon_variables:  gon.all_variables,
        market_groups:  @market_groups,
        currencies:     Currency.enabled.order(id: :asc).map { |c| { code: c.code, type: c.type } },
        current_member: @member,
        markets:        @markets.map { |m| m.as_json.merge!(ticker: Global[m].ticker) },
        my_accounts:    accounts,
        csrf_token:     form_authenticity_token
      }
    end

  end
end
