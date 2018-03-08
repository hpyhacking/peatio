module APIv2
  module Auth
    module Utils
      class << self
        def cache
          # Simply use rack-attack cache wrapper
          @cache ||= Rack::Attack::Cache.new
        end

        def jwt_shared_secret_key
          OpenSSL::PKey::RSA.new(Base64.urlsafe_decode64(Rails.application.secrets.jwt_shared_secret_key))
        end
      end
    end
  end
end
