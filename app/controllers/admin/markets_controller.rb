# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class MarketsController < BaseController
    load_and_authorize_resource

    def index
      @markets = Market.page(params[:page]).per(100)
    end

    def new
      @market = Market.new
      render :show
    end

    def create
      @market = Market.new(market_params)
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
        redirect_to :back
      end
    end

  private

    def market_params
      params.require(:trading_pair).except(:id).permit(permitted_market_attributes).tap do |params|
        boolean_market_attributes.each do |param|
          next unless params.key?(param)
          params[param] = params[param].in?(['1', 'true', true])
        end
      end
    end

    def permitted_market_attributes
      [ :bid_unit,
        :bid_fee,
        :bid_precision,
        :ask_unit,
        :ask_fee,
        :ask_precision,
        :enabled,
        :position ]
    end

    def boolean_market_attributes
      %i[ enabled ]
    end
  end
end
