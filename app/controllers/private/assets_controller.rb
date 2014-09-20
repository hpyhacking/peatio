module Private
  class AssetsController < BaseController
    before_action :auth_activated!

    def index
      @cny_assets  = Currency.assets('cny')
      @btc_proof   = Proof.current :btc
      @cny_proof   = Proof.current :cny
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
