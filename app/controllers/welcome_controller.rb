class WelcomeController < ApplicationController
  layout 'landing'

  def index
    if current_user
      redirect_to market_path(current_market) and return
    end
  end
end
