# encoding: UTF-8
# frozen_string_literal: true

require 'stringio'

module ManagementAPIv1
  class JWTAuthenticationMiddleware < Grape::Middleware::Base
    extend Memoist

    def before
      return if request.path == '/management_api/v1/swagger'
      check_request_method!
      check_query_parameters!
      check_content_type!
      payload = check_jwt!(jwt)
      env['rack.input'] = StringIO.new(payload.fetch(:data, {}).to_json)
    end

  private

    def request
      Grape::Request.new(env)
    end
    memoize :request

    def jwt
      JSON.parse(request.body.read)
    rescue => e
      raise Exceptions::Authentication, \
        message:       'Couldn\'t parse JWT.',
        debug_message: e.inspect,
        status:        400
    end
    memoize :jwt

    def check_request_method!
      unless request.post? || request.put? || request.delete?
        raise Exceptions::Authentication, \
          message: 'Only POST, PUT, and DELETE verbs are allowed.',
          status:  405
      end
    end

    def check_query_parameters!
      unless request.GET.empty?
        raise Exceptions::Authentication, \
          message: 'Query parameters are not allowed.',
          status:  400
      end
    end

    def check_content_type!
      unless request.content_type == 'application/json'
        raise Exceptions::Authentication, \
          message: 'Only JSON body is accepted.',
          status:  400
      end
    end

    def check_jwt!(jwt)
      security_configuration = Rails.configuration.x.security_configuration
      begin
        scope    = security_configuration.fetch(:scopes).fetch(security_scope)
        keychain = security_configuration
                    .fetch(:keychain)
                    .slice(*scope.fetch(:permitted_signers))
                    .each_with_object({}) { |(k, v), memo| memo[k] = v.fetch(:value) }
        result   = JWT::Multisig.verify_jwt(jwt, keychain, security_configuration.fetch(:jwt, {}))
      rescue => e
        raise Exceptions::Authentication, \
          message:       'Failed to verify JWT.',
          debug_message: e.inspect,
          status:        401
      end

      unless (scope.fetch(:mandatory_signers) - result[:verified]).empty?
        raise Exceptions::Authentication, \
          message: 'Not enough signatures for the action.',
          status:  401
      end

      result[:payload]
    end

    def security_scope
      request.env['api.endpoint'].options.fetch(:route_options).fetch(:scope)
    end
  end
end
