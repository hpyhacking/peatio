class WelcomeController < ApplicationController
  def index
    @markets = Market.all
  end
end
