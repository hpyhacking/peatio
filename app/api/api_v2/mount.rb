# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'api_v2/errors'
require_dependency 'api_v2/validations'
require_dependency 'api_v2/withdraws'

module APIv2
  class Mount < Grape::API
    PREFIX = '/api'
    API_VERSION = 'v2'

    version API_VERSION, using: :path

    cascade false

    format         :json
    content_type   :json, 'application/json'
    default_format :json

    helpers APIv2::Helpers

    do_not_route_options!

    logger Rails.logger.dup
    logger.formatter = GrapeLogging::Formatters::Rails.new
    use GrapeLogging::Middleware::RequestLogger,
        logger:    logger,
        log_level: :info,
        include:   [GrapeLogging::Loggers::Response.new,
                    GrapeLogging::Loggers::FilterParameters.new,
                    GrapeLogging::Loggers::ClientEnv.new,
                    GrapeLogging::Loggers::RequestHeaders.new]

    use APIv2::Auth::Middleware

    include Constraints
    include ExceptionHandlers

    use APIv2::CORS::Middleware

    mount APIv2::Accounts
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
    mount APIv2::Sessions
    mount APIv2::Fees
    mount APIv2::MemberLevels
    mount APIv2::Currencies

    # The documentation is accessible at http://localhost:3000/swagger?url=/api/v2/swagger
    add_swagger_documentation base_path:   PREFIX,
                              mount_path:  '/swagger',
                              api_version: API_VERSION,
                              doc_version: Peatio::Application::VERSION,
                              info: {
                                title:         "Member API #{API_VERSION}",
                                description:   'Member API is API which can be used by client application like SPA.',
                                contact_name:  'peatio.tech',
                                contact_email: 'hello@peatio.tech',
                                contact_url:   'https://www.peatio.tech',
                                licence:       'MIT',
                                license_url:   'https://github.com/rubykube/peatio/blob/master/LICENSE.md'
                              },
                              models: [
                                Entities::Currency, Entities::Account
                              ],
                              security_definitions: {
                                Bearer: {
                                  type: "apiKey",
                                  name: "JWT",
                                  in: "header"
                                }
                              }
  end
end
