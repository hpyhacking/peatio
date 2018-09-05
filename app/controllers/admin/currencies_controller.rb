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
        enabled
        blockchain_key
      ]

      if @currency.new_record?
        attributes += %i[
          code
          type
          base_factor
          precision
          erc20_contract_address ]
      end

      attributes
    end

    def boolean_currency_attributes
      %i[ enabled ]
    end
  end
end
