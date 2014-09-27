class WelcomeController < ApplicationController
  def index
    @markets = Market.all.sort
    @current_market = @markets.first
  end
end
