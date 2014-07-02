class WelcomeController < ApplicationController
  layout 'landing'

  def index
    if current_user
      redirect_to market_path(current_market) and return
    end

    @btc_balance = Proof.current(:btc).try(:balance)
    @cny_balance  = Proof.current(:cny).try(:balance)
  end
end
