require_dependency 'api_v2/errors'
require_dependency 'api_v2/validations'
require_dependency 'api_v2/withdraws'

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

    mount APIv2::Markets
    mount APIv2::Tickers
    mount APIv2::Members
    mount APIv2::Deposits
    mount APIv2::Orders
    mount APIv2::OrderBooks
    mount APIv2::Trades
    mount APIv2::K
    mount APIv2::Tools
    mount APIv2::Withdraws

    base_path = Rails.env.production? ? "#{ENV['URL_SCHEME']}://#{ENV['URL_HOST']}/#{PREFIX}" : PREFIX
    add_swagger_documentation base_path: base_path,
      mount_path: '/doc/swagger', api_version: 'v2',
      hide_documentation_path: true
  end
end
