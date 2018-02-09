module Private
  class AssetsController < BaseController
    skip_before_action :auth_member!, only: [:index]

    def index
      @fiat_assets = Currency.assets(Peatio.base_fiat_ccy.downcase)

      Currency.all.each do |ccy|
        name = ccy.fiat? ? :fiat : ccy.code.downcase.to_sym
        instance_variable_set :"@#{name}_proof", Proof.current(ccy.code.downcase.to_sym)
        if current_user
          instance_variable_set :"@#{name}_account", \
            current_user.accounts.with_currency(ccy.code.downcase.to_sym).first
        end
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
