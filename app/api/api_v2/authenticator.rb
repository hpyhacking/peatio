module APIv2
  class Authenticator

    class <<self

      def urlsafe_string_40
        # 30 is picked so generated string length is 40
        SecureRandom.urlsafe_base64(30).tr('_-', 'xx')
      end

      alias :generate_access_key :urlsafe_string_40
      alias :generate_secret_key :urlsafe_string_40

      def hmac_signature(secret_key, payload)
        OpenSSL::HMAC.hexdigest 'SHA256', secret_key, payload
      end

    end

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
      @params[:signature] == self.class.hmac_signature(token.secret_key, payload)
    end

    def fresh?
      timestamp = Time.at(@params[:tonce].to_i / 1000.0)
      timestamp > 5.minutes.ago
    end

    def payload
      hash = @params.select {|k,v| !%w(route_info signature).include?(k) }
      URI.unescape(hash.to_param)
    end

  end
end
