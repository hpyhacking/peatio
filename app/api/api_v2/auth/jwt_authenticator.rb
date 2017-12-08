module APIv2
  module Auth
    class JWTAuthenticator
      def initialize(token)
        @token_type, @token_value = token.to_s.split(' ')
      end

      #
      # Decodes and verifies JWT.
      # Returns authentic member email or raises an exception.
      #
      # @return [String]
      def authenticate!
        unless @token_type == 'Bearer'
          raise AuthorizationError, 'Token type is not provided or invalid.'
        end

        payload, header = decode_and_verify_token(@token_value)

        fetch_email(payload)
      end

    private

      def decode_and_verify_token(token)
        JWT.decode(token, Utils.jwt_shared_secret_key, true)
      rescue JWT::DecodeError => e
        Rails.logger.error { e.inspect }
        raise AuthorizationError, 'Token is invalid or expired.'
      end

      def fetch_email(payload)
        email = payload['email'].to_s.squish

        raise(AuthorizationError, 'E-Mail is blank.') if email.blank?
        raise(AuthorizationError, 'E-Mail is invalid.') unless EmailValidator.valid?(email)

        email
      end
    end
  end
end
