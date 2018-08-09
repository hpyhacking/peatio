# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class CurrenciesController < BaseController
    def index
      @currencies = Currency.page(params[:page]).per(100)
    end

    def new
      @currency = Currency.new
      render :show
    end

    def create
      @currency = Currency.new
      @currency.assign_attributes(currency_params)
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
      params.require(:currency).permit(permitted_currency_attributes).tap do |params|
        boolean_currency_attributes.each do |param|
          next unless params.key?(param)
          params[param] = params[param].in?(['1', 'true', true])
        end
      end
    end

    def permitted_currency_attributes
      attributes = %i[
        symbol
        icon_url
        quick_withdraw_limit
        withdraw_fee
        deposit_fee
        min_confirmations
        enabled
        allow_multiple_deposit_addresses
        blockchain_key
      ]

      if @currency.new_record?
        attributes += %i[
          code
          type
          base_factor
          precision
          api_client
          json_rpc_endpoint
          rest_api_endpoint
          bitgo_test_net
          bitgo_wallet_id
          bitgo_wallet_address
          bitgo_wallet_passphrase
          bitgo_rest_api_root
          bitgo_rest_api_access_token
          case_sensitive
          erc20_contract_address
          supports_cash_addr_format
          supports_hd_protocol ]
      end

      attributes
    end

    def boolean_currency_attributes
      %i[ enabled
          case_sensitive
          supports_cash_addr_format
          bitgo_test_net
          supports_hd_protocol
          allow_multiple_deposit_addresses ]
    end
  end
end
