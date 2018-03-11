module APIv2
  module Auth
    module Utils
      class << self
        def cache
          # Simply use rack-attack cache wrapper
          @cache ||= Rack::Attack::Cache.new
        end

        def jwt_public_key
          OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV.fetch('JWT_PUBLIC_KEY')))
        end
      end
    end
  end
end
