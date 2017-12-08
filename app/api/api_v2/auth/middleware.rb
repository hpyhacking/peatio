module APIv2
  module Auth
    class Middleware < Grape::Middleware::Base
      def before
        if auth_by_keypair?
          auth = KeypairAuthenticator.new(request, params)
          env['api_v2.keypair_token']       = auth.authenticate!
          env['api_v2.authentic_member_id'] = env['api_v2.keypair_token'].member_id
        elsif auth_by_jwt?
          env['api_v2.authentic_member_email'] = \
            JWTAuthenticator.new(headers['Authorization']).authenticate!
        end
      end

    private
      
      def auth_by_keypair?
        params[:access_key] && params[:tonce] && params[:signature]
      end

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
