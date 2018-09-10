# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Currencies < Grape::API
    helpers ::APIv2::NamedParams

    TradeStruct = Struct.new(:price, :volume, :change)

    desc 'Get currency trades at last 24h', tags: %w[currencies]
    params do
      requires :currency, type: String,
                          values: -> { Currency.enabled.codes(bothcase: true) },
                          desc: -> { APIv2::Entities::Currency.documentation[:id] }
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

    desc 'Get a currency', tags: %w[currencies], success: Entities::Currency
    params do
      requires :id, type: String,
                    values: -> { Currency.enabled.codes(bothcase: true) },
                    desc: -> { APIv2::Entities::Currency.documentation[:id][:desc] }
    end
    get '/currencies/:id' do
      present Currency.find(params[:id]), with: APIv2::Entities::Currency
    end

    desc 'Get list of currencies', is_array: true,
                                   success: Entities::Currency,
                                   tags: %w[currencies],
                                   security: []
    params do
      optional :type, type: String,
                      values: %w[fiat coin],
                      desc: -> { APIv2::Entities::Currency.documentation[:type][:desc] }
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
