class WelcomeController < ApplicationController
  def index
    @markets = Market.all.sort
  end
end
