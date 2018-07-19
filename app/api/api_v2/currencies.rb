# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Currencies < Grape::API
    helpers ::APIv2::NamedParams

    TradeStruct = Struct.new(:price, :volume, :change)

    desc 'Get currency trades at last 24h'
    params do
      requires :currency, type: String, values: -> { Currency.enabled.codes(bothcase: true) }, desc: -> { "Available values: #{Currency.coins.enabled.codes(bothcase: true).join(', ')}" }
    end
    get '/currency/trades' do
      currency = params[:currency]

      Market.enabled.with_base_unit(currency).map do |market|
        price  = Trade.avg_h24_price(market)
        volume = market.ticker[:volume]
        change = market.change_ratio

        { market.quote_unit => TradeStruct.new(price, volume, change) }
      end
    end

    desc 'Get currency by id'
    params do
      requires :id, type: String, values: -> { Currency.enabled.codes(bothcase: true) }, desc: -> { APIv2::Entities::Currency.documentation[:id] }
    end
    get '/currencies/:id' do
      id = params[:id]
      present Currency.find_by_id(id), with: APIv2::Entities::Currency
    end

    desc 'Get list of currencies'
    params do
      optional :type, type: String, values: %w[fiat coin], desc: -> { APIv2::Entities::Currency.documentation[:type] }
    end
    get '/currencies' do
      if params[:type].blank?
        currencies = Currency.enabled
      else
        type = params[:type]
        currencies = Currency.enabled.where(type: type)
      end

      present currencies, with: APIv2::Entities::Currency
    end
  end
end
