module Private
  class AssetsController < BaseController
    skip_before_action :auth_member!, only: [:index]

    def index
      @fiat_assets = Currency.assets(Peatio.base_fiat_ccy.downcase)
      @btc_proof   = Proof.current :btc
      @bch_proof   = Proof.current :bch
      @ltc_proof   = Proof.current :ltc
      @fiat_proof  = Proof.current Peatio.base_fiat_ccy_sym.downcase
      @xrp_proof   = Proof.current :xrp
      @dash_proof  = Proof.current :dash

      if current_user
        @btc_account  = current_user.accounts.with_currency(:btc).first
        @bch_account  = current_user.accounts.with_currency(:bch).first
        @ltc_account  = current_user.accounts.with_currency(:ltc).first
        @fiat_account = current_user.accounts.with_currency(Peatio.base_fiat_ccy_sym.downcase).first
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
