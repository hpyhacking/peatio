module APIv2
  module CORS
    class Middleware < Grape::Middleware::Base
      def call(env)
        request = Grape::Request.new(env)
        if request.options?
          [200, cors, []]
        else
          response = @app.call(env)
          response.headers.reverse_merge!(cors)

          # Response may differ if server specifies "*" as allowed origins.
          # See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
          if response.headers['Access-Control-Allow-Origin'] != '*'
            response.headers['Vary'] = [response.headers['Vary'], 'Origin'].compact.join(', ')
          end
          response
        end
      end

    private

      def request
        @request ||= Grape::Request.new(env)
      end

      def cors
        { 'Access-Control-Allow-Origin'  => cors_origins,
          'Access-Control-Allow-Methods' => 'GET, POST, PUT, PATCH, DELETE',
          'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
        }
      end

      def cors_origins
        ENV.fetch('API_CORS_ORIGINS')
      end
    end
  end
end
