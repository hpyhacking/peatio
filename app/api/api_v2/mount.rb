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

    do_not_route_head!
    do_not_route_options!

    use APIv2::Auth::Middleware

    include Constraints
    include ExceptionHandlers

    mount Markets
    mount Tickers
    mount Members
    mount Orders
    mount OrderBooks
    mount Trades

    base_path = Rails.env.production? ? "#{ENV['URL_SCHEMA']}://#{ENV['URL_HOST']}" : nil
    add_swagger_documentation base_path: base_path,
      mount_path: '/doc/swagger', api_version: 'v2',
      hide_documentation_path: true
  end
end
