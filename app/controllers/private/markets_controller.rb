module Private
  class MarketsController < BaseController
    include Concerns::DisableMarketsUI

    skip_before_action :auth_member!, only: [:show]
    before_action :visible_market?
    after_action :set_default_market

    layout false

    def show
      @bid = params[:bid]
      @ask = params[:ask]

      @market        = current_market
      @markets       = Market.all.sort
      @market_groups = @markets.map(&:quote_unit).uniq

      @bids   = @market.bids
      @asks   = @market.asks
      @trades = @market.trades

      # default to limit order
      @order_bid = OrderBid.new ord_type: 'limit'
      @order_ask = OrderAsk.new ord_type: 'limit'

      set_member_data if current_user
      gon.jbuilder
      render json: trading_ui_variables
    end

    private

    def visible_market?
      redirect_to market_path(Market.first) if not current_market.visible?
    end

    def set_default_market
      cookies[:market_id] = @market.id
    end

    def set_member_data
      @member = current_user
      @orders_wait = @member.orders.with_currency(@market).with_state(:wait)
      @trades_done = Trade.for_member(@market.id, current_user, limit: 100, order: 'id desc')
    end

    def trading_ui_variables
      markets = @markets.map do |m|
        { id:         m.id,
          name:       m.name,
          quote_unit: m.quote_unit,
          base_unit:  m.base_unit,
          ticker:     Global[m].ticker }
      end

      accounts = @member&.accounts&.map do |x|
        { id:         x.id,
          locked:     x.locked,
          amount:     x.amount,
          currency:   {
            code:     x.currency.code,
            symbol:   x.currency.symbol,
            type:     x.currency.type,
            icon_url: if x.currency.coin?
                        ActionController::Base.helpers.image_url "/icon-#{x.currency.code}.png"
                      else
                        ActionController::Base.helpers.image_url "yarn_components/currency-flags/src/flags/#{x.currency.code}.png"
                      end } }
      end

      { current_market: @market.as_json.tap { |data| data.merge!(data.delete('attributes')) },
        gon_variables:  gon.all_variables,
        market_groups:  @market_groups,
        currencies:     Currency.order(id: :asc).map { |c| { code: c.code, type: c.type } },
        current_member: @member,
        markets:        markets,
        my_accounts:    accounts,
        csrf_token:     form_authenticity_token
      }
    end

  end
end
