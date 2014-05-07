module Private
  class AssetsController < BaseController
    layout 'application', only: [:index]

    before_action :auth_activated!

    def index
      @cny_assets  = Currency.assets('cny')
      @btc_proof   = select_proof :btc
      @cny_proof   = select_proof :cny
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

    private

    def select_proof(code)
      scope = Proof.with_currency(code)
      scope.where('created_at <= ?', 1.day.ago).last || scope.last
    end

  end
end
