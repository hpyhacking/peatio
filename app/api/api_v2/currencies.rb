# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Currencies < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get currency trades at last 24h'
    params do
      requires :currency, type: String, values: -> { Currency.enabled.codes(bothcase: true) }, desc: -> { "Available values: #{Currency.coins.enabled.codes(bothcase: true).join(', ')}" }
    end
    get "/currency/trades" do
      trades = Market.enabled.with_base_unit(params[:currency]).map do |market|
       {"#{market.quote_unit}" => {price: Trade.avg_h24_price(market), volume: market.ticker[:volume], change: market.change_ratio } }
      end
    end

  end
end
