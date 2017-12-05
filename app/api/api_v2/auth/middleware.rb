module APIv2
  module Auth
    class Middleware < ::Grape::Middleware::Base
      def before
        if auth_by_keypair?
          auth = KeypairAuthenticator.new(request, params)
          env['api_v2.keypair_token'] = auth.authenticate!
          env['api_v2.member']        = env['api_v2.keypair_token'].member
        end
      end

    private
      
      def auth_by_keypair?
        params[:access_key] && params[:tonce] && params[:signature]
      end

      def request
        @request ||= ::Grape::Request.new(env)
      end

      def params
        @params ||= request.params
      end
    end
  end
end
