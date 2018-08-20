# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Auth
    class Middleware < Grape::Middleware::Base
      def before
        return unless auth_by_jwt?

        env['api_v2.authentic_member_email'] = \
          JWTAuthenticator.new(headers['Authorization']).authenticate!(return: :email)
      end
    private

      def auth_by_jwt?
        headers.key?('Authorization')
      end

      def request
        @request ||= Grape::Request.new(env)
      end

      def params
        request.params
      end

      def headers
        request.headers
      end
    end
  end
end
