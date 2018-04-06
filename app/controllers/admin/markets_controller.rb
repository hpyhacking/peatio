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
      params.require(:trading_pair)
            .except(:id)
            .permit(:bid_unit, :bid_fee, :bid_precision, :ask_unit, :ask_fee, :ask_precision, :visible, :position)
    end
  end
end
