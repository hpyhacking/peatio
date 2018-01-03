require_relative 'errors'
require_relative 'validations'

module APIv2
  class Mount < Grape::API
    PREFIX = '/api'

    version 'v2', using: :path

    cascade false

    format         :json
    content_type   :json, 'application/json'
    default_format :json

    helpers APIv2::Helpers

    do_not_route_options!

    use APIv2::Auth::Middleware

    include Constraints
    include ExceptionHandlers

    use APIv2::CORS::Middleware

    mount Markets
    mount Tickers
    mount Members
    mount Deposits
    mount Orders
    mount OrderBooks
    mount Trades
    mount K
    mount Tools

    base_path = Rails.env.production? ? "#{ENV['URL_SCHEME']}://#{ENV['URL_HOST']}/#{PREFIX}" : PREFIX
    add_swagger_documentation base_path: base_path,
      mount_path: '/doc/swagger', api_version: 'v2',
      hide_documentation_path: true
  end
end
