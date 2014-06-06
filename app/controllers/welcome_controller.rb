class WelcomeController < ApplicationController
  layout 'landing'

  def index
    if current_user
      redirect_to market_path(current_market) and return
    end

    @btc_balance = Currency.assets('btc')['balance']
    @cny_balance  = Currency.assets('cny')['balance']
  end
end
