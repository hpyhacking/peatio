module OpendaxCloud
  class Client
    Error = Class.new(StandardError)

    class ConnectionError < Error; end
    class MissingEnvError < Error; end

    def initialize(endpoint, idle_timeout: 5)
      @platform_id = ENV.fetch('PLATFORM_ID') do
        raise MissingEnvError, :platform_id
      end

      @endpoint = URI.parse(endpoint)
      @private_key = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV.fetch('PEATIO_JWT_PRIVATE_KEY')))
      @path = @endpoint.path.empty? ? "/" : @endpoint.path
      @idle_timeout = idle_timeout
    end

    def rest_api(verb, path, data = nil)
      args = [@endpoint.to_s + path]
      jwt = JWT.encode(data, @private_key, 'RS256')

      headers = { 'Content-Type' => 'application/json',
                  'Authorization' => 'Bearer ' + jwt,
                  'Accept' => 'application/json',
                  'PlatformID' => @platform_id }

      if data.present?
        if %i[post put patch].include?(verb)
          args << data.compact.to_json << headers
        else
          args << data.compact << headers
        end
      else
        args << data << headers
      end

      response = connection.send(verb, *args)
      response.assert_success!
      JSON.parse(response.body)
    rescue Faraday::Error => e
      raise ConnectionError, e
    rescue StandardError => e
      raise Error, e
    end

    private

    def connection
      @connection ||= Faraday.new(@endpoint) do |f|
        f.adapter :net_http_persistent, pool_size: 5, idle_timeout: @idle_timeout
      end
    end
  end
end
