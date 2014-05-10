module APIv2
  module Auth
    class Middleware < ::Grape::Middleware::Base

      def before
        @env['api_v2.token'] = authenticate!
      end

      def authenticate!
        return unless provided?
        auth = Authenticator.new(request, params)
        auth.authentic? ? auth.token : nil
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
