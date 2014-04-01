module Private
  class AssetsController < BaseController
    layout 'application', only: [:index]

    before_action :auth_activated!

    def index
      @btc_assets  = Currency.assets('btc')
      @cny_assets  = Currency.assets('cny')
      @btc_proof   = Proof.with_currency(:btc).last
      @cny_proof   = Proof.with_currency(:cny).last
      @btc_account = current_user.accounts.with_currency(:btc).first
      @cny_account = current_user.accounts.with_currency(:cny).first
    end

    def partial_tree
      account    = current_user.accounts.with_currency(params[:id]).first
      @timestamp = Proof.with_currency(params[:id]).last.timestamp
      @json      = account.partial_tree.to_json.html_safe
      respond_to do |format|
        format.js
      end
    end

  end
end
