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
      # @param [Hash] options
      # @return [String, Member, NilClass]
      def authenticate!(options = {})
        unless @token_type == 'Bearer'
          raise AuthorizationError, 'Token type is not provided or invalid.'
        end

        payload, header = decode_and_verify_token(@token_value)
        fetch_member(payload).yield_self do |member|
          options[:return] == :member ? member : fetch_email(payload)
        end
      rescue => e
        report_exception(e)
        if AuthorizationError === e
          raise e
        else
          raise AuthorizationError, e.inspect
        end
      end

      #
      # Exception-safe version of #authenticate!.
      #
      # @return [String, Member, NilClass]
      def authenticate(*args)
        authenticate!(*args)
      rescue
        nil
      end

    private

      def decode_and_verify_token(token)
        JWT.decode(token, Utils.jwt_public_key, true, token_verification_options)
           .tap { |pair| pair[0].symbolize_keys! }
      rescue JWT::DecodeError => e
        raise AuthorizationError, "Failed to decode and verify JWT: #{e.inspect}."
      end

      def fetch_email(payload)
        payload[:email].to_s.tap do |email|
          raise(AuthorizationError, 'E-Mail is blank.') if email.blank?
          raise(AuthorizationError, 'E-Mail is invalid.') unless EmailValidator.valid?(email)
        end
      end

      def fetch_uid(payload)
        payload.fetch(:uid).tap { |uid| raise(AuthorizationError, 'UID is blank.') if uid.blank? }
      end

      def fetch_scopes(payload)
        Array.wrap(payload[:scopes]).map(&:to_s).map(&:squash).reject(&:blank).tap do |scopes|
          raise(AuthorizationError, 'Token scopes are not defined.') if scopes.empty?
        end
      end

      def fetch_member(payload)
        if payload[:iss] == 'barong'
          from_barong_payload(payload)
        else
          Member.find_by_email(fetch_email(payload))
        end
      end

      def from_barong_payload(payload)
        Member.find_or_initialize_by(email: fetch_email(payload)).tap do |member|
          member.transaction do
            member.level    = Member::Levels.from_numerical_barong_level(payload.fetch(:level).to_i)
            member.disabled = payload.fetch(:state).to_s != 'active'
            member.save!
            member.authentications.find_or_initialize_by(provider: 'barong', uid: fetch_uid(payload)).save!
          end
        end
      end

      def token_verification_options
        { verify_expiration: true,
          verify_not_before: true,
                             # Set option only if it is not blank.
          iss:               ENV['JWT_ISSUER'].to_s.squish.presence,
          verify_iss:        ENV['JWT_ISSUER'].present?,
          verify_iat:        true,
          verify_jti:        true,
                             # Support comma-separated JWT_AUDIENCE variable.
                             # We are rejecting blank values from the list here.
          aud:               ENV['JWT_AUDIENCE'].to_s.split(',').map(&:squish).reject(&:blank?).presence,
          verify_aud:        ENV['JWT_AUDIENCE'].present?,
          sub:               'session',
          verify_sub:        true,
          algorithms:        [ENV.fetch('JWT_ALGORITHM')],
          leeway:            ENV['JWT_DEFAULT_LEEWAY'].to_s.squish.yield_self { |n| n.to_i if n.present? },
          iat_leeway:        ENV['JWT_ISSUED_AT_LEEWAY'].to_s.squish.yield_self { |n| n.to_i if n.present? },
          exp_leeway:        ENV['JWT_EXPIRATION_LEEWAY'].to_s.squish.yield_self { |n| n.to_i if n.present? },
          nbf_leeway:        ENV['JWT_NOT_BEFORE_LEEWAY'].to_s.squish.yield_self { |n| n.to_i if n.present? }
        }.compact
      end
    end
  end
end
