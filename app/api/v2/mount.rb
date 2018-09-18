# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'v2/errors'
require_dependency 'v2/validations'

module API
  module V2
    class Mount < Grape::API
      PREFIX = '/api'
      API_VERSION = 'v2'


      format         :json
      content_type   :json, 'application/json'
      default_format :json

      helpers V2::Helpers

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

      use V2::Auth::Middleware

      include Constraints
      include ExceptionHandlers

      mount Public::Mount => 'public'
      mount Account::Mount => 'account'
      mount Market::Mount => 'market'
      mount Management::Mount => 'management'

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
end
