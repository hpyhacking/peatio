# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Tickers < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get ticker of all markets.'
    get "/tickers" do
      Market.enabled.ordered.inject({}) do |h, m|
        h[m.id] = format_ticker Global[m.id].ticker
        h
      end
    end

    desc 'Get ticker of specific market.'
    params do
      use :market
    end
    get "/tickers/:market" do
      format_ticker Global[params[:market]].ticker
    end

  end
end
