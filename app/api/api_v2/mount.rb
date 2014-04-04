require_relative 'errors'

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

    # Public APIs
    mount Tickers

    # Private APIs
    group do
      before { authenticate! }
      mount Orders
    end
  end
end
