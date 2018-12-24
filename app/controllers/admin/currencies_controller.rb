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
      params.require(:currency).permit(permitted_currency_attributes).tap do |whitelist|
        boolean_currency_attributes.each do |param|
          next unless whitelist.key?(param)
          whitelist[param] = whitelist[param].in?(['1', 'true', true])
        end
        whitelist[:options] = params[:currency][:options].is_a?(String) ? \
                                  JSON.parse(params[:currency][:options]) : params[:currency][:options] \
                                  if params[:currency][:options]
      end
    end

    def permitted_currency_attributes
      attributes = %i[
        name
        symbol
        icon_url
        deposit_fee
        min_deposit_amount
        min_collection_amount
        withdraw_fee
        min_withdraw_amount
        withdraw_limit_24h
        withdraw_limit_72h
        enabled
        blockchain_key
      ]

      if @currency.new_record?
        attributes += %i[
          code
          type
          base_factor
          precision ]
      end

      attributes
    end

    def boolean_currency_attributes
      %i[ enabled ]
    end
  end
end
