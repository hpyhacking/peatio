module Private
  class AssetsController < BaseController
    before_action :auth_activated!

    def index
      @proof = Proof.current
      @btc_account = current_user.accounts.with_currency(:btc).first
      @cny_account = current_user.accounts.with_currency(:cny).first
    end

  end
end
