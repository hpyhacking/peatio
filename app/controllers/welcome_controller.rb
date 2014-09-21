class WelcomeController < ApplicationController
  def index
    if current_user
      redirect_to market_path(current_market) and return
    end

    @markets = Market.all
  end
end
