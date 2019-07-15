# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Auth
      class Middleware < Grape::Middleware::Base
        def before
          return unless auth_by_jwt?

          # TODO: UID should be used for member identify.
          env['api_v2.authentic_member_email'] = \
            JWTAuthenticator.new(request.headers['Authorization']).authenticate
        end
      private

         def auth_by_jwt?
          request.headers.key?('Authorization')
        end

        def request
          @request ||= Grape::Request.new(env)
        end

        def params
          request.params
        end
      end
    end
  end
end
