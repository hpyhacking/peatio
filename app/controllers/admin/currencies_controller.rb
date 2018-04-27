module Admin
  class CurrenciesController < BaseController
    load_and_authorize_resource

    def index
      @currencies = Currency.page(params[:page]).per(100)
    end

    def new
      @currency = Currency.new
      render :show
    end

    def create
      @currency = Currency.new(currency_params)
      if @currency.save
        redirect_to admin_currencies_path
      else
        flash[:alert] = @currency.errors.full_messages.first
        render :show
      end
    end

    def show
      @currency = Currency.find(params[:id])
    end

    def update
      @currency = Currency.find(params[:id])
      if @currency.update(currency_params)
        redirect_to admin_currencies_path
      else
        flash[:alert] = @currency.errors.full_messages.first
        redirect_to :back
      end
    end

    private
    def currency_params
      params.require(:currency)
            .permit :code,
                    :symbol,
                    :type,
                    :quick_withdraw_limit,
                    :withdraw_fee,
                    :deposit_fee,
                    :deposit_confirmations,
                    :visible,
                    :base_factor,
                    :precision,
                    :api_client,
                    :json_rpc_endpoint,
                    :rest_api_endpoint,
                    :bitgo_test_net,
                    :bitgo_wallet_id,
                    :bitgo_wallet_address,
                    :bitgo_wallet_passphrase,
                    :bitgo_rest_api_root,
                    :bitgo_rest_api_access_token,
                    :wallet_url_template,
                    :transaction_url_template
    end
  end
end
