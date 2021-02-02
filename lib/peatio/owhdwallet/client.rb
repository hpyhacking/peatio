module OWHDWallet
  class Client
    Error = Class.new(StandardError)

    class ConnectionError < Error; end

    def initialize(endpoint, idle_timeout: 5)
      @endpoint = URI.parse(endpoint)
      @private_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV.fetch('PEATIO_JWT_PRIVATE_KEY')))
      @path = @endpoint.path.empty? ? "/" : @endpoint.path
      @idle_timeout = idle_timeout
    end

    def rest_api(verb, path, data = nil)
      args = [@endpoint.to_s + path]
      jwt = JWT.encode({}, @private_key, 'RS256')

      if data
        if %i[post put patch].include?(verb)
          args << data.compact.to_json
          args << { 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + jwt }
        else
          args << data.compact
          args << {}
        end
      else
        args << nil
        args << {}
      end

      args.last['Accept'] = 'application/json'

      response = connection.send(verb, *args)
      response.assert_success!
      response = JSON.parse(response.body)
    rescue Faraday::Error => e
      raise ConnectionError, e
    rescue StandardError => e
      raise Error, e
    end

    private

    def connection
      ca_file_path = ENV.fetch('HDWALLET_SSL_CERT_PATH', '')
      ssl = if ca_file_path.present?
              { ca_file: ca_file_path }
            else
              Rails.logger.warn { "Peer verification turned off. SSL connection { verify: false }" }
              { verify: false }
            end

      @connection ||= Faraday.new(@endpoint, { ssl: ssl }) do |f|
        f.adapter :net_http_persistent, pool_size: 5, idle_timeout: @idle_timeout
      end
    end
  end
end
