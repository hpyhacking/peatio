module APIv2
  module Auth
    class Authenticator

      def initialize(request, params)
        @request = request
        @params  = params
      end

      def authentic?
        token && signature_match? && fresh?
      end

      def token
        @token ||= APIToken.where(access_key: @params[:access_key]).first
      end

      def signature_match?
        @params[:signature] == Utils.hmac_signature(token.secret_key, payload)
      end

      def fresh?
        key = "api_v2:tonce:#{token.access_key}"
        last_tonce = Utils.cache.read key
        return false if last_tonce && last_tonce >= tonce
        Utils.cache.write key, tonce, nil

        timestamp = Time.at(tonce / 1000.0)
        timestamp > 5.minutes.ago
      end

      def tonce
        @tonce ||= @params[:tonce].to_i
      end

      def payload
        "#{canonical_verb}|#{canonical_uri}|#{canonical_query}"
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

    end
  end
end
