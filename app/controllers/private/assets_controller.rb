module Private
  class AssetsController < BaseController
    skip_before_action :auth_member!, only: [:index]

    def index
      @usd_assets = Currency.assets('usd')
      @btc_proof  = Proof.current :btc
      @bch_proof  = Proof.current :bch
      @ltc_proof  = Proof.current :ltc
      @usd_proof  = Proof.current :usd
      @xrp_proof  = Proof.current :xrp
      @dash_proof = Proof.current :dash

      if current_user
        @btc_account  = current_user.accounts.with_currency(:btc).first
        @bch_account  = current_user.accounts.with_currency(:bch).first
        @ltc_account  = current_user.accounts.with_currency(:ltc).first
        @usd_account  = current_user.accounts.with_currency(:usd).first
        @xrp_account  = current_user.accounts.with_currency(:xrp).first
        @dash_account = current_user.accounts.with_currency(:dash).first
      end
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
