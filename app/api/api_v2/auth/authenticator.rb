module APIv2
  module Auth
    class Authenticator

      def initialize(request, params)
        @request = request
        @params  = params
      end

      def authenticate!
        check_token!
        check_tonce!
        check_signature!
        token
      end

      def token
        @token ||= APIToken.joins(:member).where(access_key: @params[:access_key]).first
      end

      def check_token!
        raise InvalidAccessKeyError, @params[:access_key] unless token
        raise DisabledAccessKeyError, @params[:access_key] if token.member.api_disabled
        raise ExpiredAccessKeyError, @params[:access_key] if token.expired?
        raise OutOfScopeError unless token.in_scopes?(route_scopes)
      end

      def check_signature!
        if @params[:signature] != Utils.hmac_signature(token.secret_key, payload)
          Rails.logger.warn "APIv2 auth failed: signature doesn't match. token: #{token.access_key} payload: #{payload}"
          raise IncorrectSignatureError, @params[:signature]
        end
      end

      def check_tonce!
        key = "api_v2:tonce:#{token.access_key}"
        last_tonce = Utils.cache.read key

        if last_tonce && last_tonce >= tonce
          Rails.logger.warn "APIv2 auth failed: used tonce. token: #{token.access_key} payload: #{payload} tonce: #{tonce} last_tonce: #{last_tonce}"
          raise TonceUsedError.new(token.access_key, tonce, last_tonce)
        end
        Utils.cache.write key, tonce, nil

        timestamp = Time.at(tonce / 1000.0)
        if timestamp <= 5.minutes.ago
          Rails.logger.warn "APIv2 auth failed: stale tonce. token: #{token.access_key} payload: #{payload} tonce: #{tonce} last_tonce: #{last_tonce}"
          raise TonceTooOldError, tonce
        end
      end

      def tonce
        @tonce ||= @params[:tonce].to_i
      end

      def payload
        "#{canonical_verb}|#{APIv2::Mount::PREFIX}#{canonical_uri}|#{canonical_query}"
      end

      def canonical_verb
        @request.request_method
      end

      def canonical_uri
        @request.path_info
      end

      def canonical_query
        hash = @params.select {|k,v| !%w(route_info signature format).include?(k) }
        URI.unescape(hash.to_param)
      end

      def endpoint
        @request.env['api.endpoint']
      end

      def route_scopes
        endpoint.options[:route_options][:scopes]
      end

    end
  end
end
