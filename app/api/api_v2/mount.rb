require 'grape-swagger'

require_relative 'errors'
require_relative 'validations'

module APIv2
  class Mount < Grape::API
    prefix 'api'
    version 'v2', using: :path

    cascade false

    format :json
    default_format :json

    helpers ::APIv2::Helpers

    include ExceptionHandlers

    do_not_route_head!
    do_not_route_options!

    MARKETS = Market.all.map(&:id)

    before do
      # Grape will add default values to params after validation
      @raw_params = params.dup
    end

    mount Markets
    mount Tickers
    mount Members
    mount Orders
    mount OrderBooks
    mount Trades

    add_swagger_documentation mount_path: '/doc/swagger', api_version: 'v2'
  end
end
