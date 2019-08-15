# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class MarketsController < BaseController
    def index
      @markets = Market.ordered.page(params[:page]).per(100)
    end

    def new
      @market = Market.new
      render :show
    end

    def create
      @market = Market.new
      @market.assign_attributes(market_params)
      if @market.save
        redirect_to admin_markets_path
      else
        flash[:alert] = @market.errors.full_messages.first
        render :show
      end
    end

    def show
      @market = Market.find(params[:id])
    end

    def update
      @market = Market.find(params[:id])
      if @market.update(market_params)
        redirect_to admin_markets_path
      else
        flash[:alert] = @market.errors.full_messages.first
        render :show
      end
    end

  private

    def market_params
      params.require(:trading_pair).except(:id).permit(permitted_market_attributes)
    end

    def permitted_market_attributes
      attributes = %i[
        base_currency
        quote_currency
        maker_fee
        taker_fee
        state
        min_price
        max_price
        min_amount
        position
      ]

      if @market.new_record?
        attributes += %i[
          amount_precision
          price_precision
        ]
      end

      attributes
    end
  end
end
