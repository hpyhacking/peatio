class WelcomeController < ApplicationController
  def index
    if current_user
      redirect_to settings_path and return
    end

    @markets = Market.all
  end
end
