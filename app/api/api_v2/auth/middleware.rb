module APIv2
  module Auth
    class Middleware < ::Grape::Middleware::Base

      def before
        if provided?
          auth = Authenticator.new(request, params)
          @env['api_v2.token'] = auth.authenticate!
        end
      end

      def provided?
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
