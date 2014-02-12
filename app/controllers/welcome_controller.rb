class WelcomeController < ApplicationController
  before_filter :auth_active!

  def index
    if current_user
      redirect_to market_path(latest_market)
    else
      redirect_to signin_path
    end
  end
end
