module Private
  class AssetsController < BaseController
    layout 'application', only: [:index]

    before_action :auth_activated!

    def index
      @btc_proof = Proof.with_currency(:btc).last
      @cny_proof = Proof.with_currency(:cny).last
      @btc_account = current_user.accounts.with_currency(:btc).first
      @cny_account = current_user.accounts.with_currency(:cny).first
    end

  end
end
