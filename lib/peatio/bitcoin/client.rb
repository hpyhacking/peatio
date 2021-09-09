module Bitcoin
  class Client
    Error = Class.new(StandardError)

    class ConnectionError < Error; end

    class ResponseError < Error
      def initialize(code, msg)
        super "#{msg} (#{code})"
      end
    end

    extend Memoist

    def initialize(endpoint, idle_timeout: 5)
      @json_rpc_endpoint = URI.parse(endpoint)
      @path = @json_rpc_endpoint.path.empty? ? "/" : @json_rpc_endpoint.path
      @idle_timeout = idle_timeout
    end

    def json_rpc(method, params = [])
      response = connection.post \
        @path,
        {jsonrpc: '1.0', method: method, params: params}.to_json,
        {'Accept' => 'application/json',
         'x-api-key' => '40e7aa11-bb47-4f22-8b4f-f9c072dd0864',
         'Content-Type' => 'application/json'}
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise ResponseError.new(error['code'], error['message']) if error }
      response.fetch('result')
    rescue Faraday::Error => e
      raise ConnectionError, e
    rescue StandardError => e
      raise Error, e
    end

    private

    def connection
      @connection ||= Faraday.new(@json_rpc_endpoint) do |f|
        f.adapter :net_http_persistent, pool_size: 5, idle_timeout: @idle_timeout
      end.tap do |connection|
        unless @json_rpc_endpoint.user.blank?
          connection.basic_auth(@json_rpc_endpoint.user, @json_rpc_endpoint.password)
        end
      end
    end
  end
end
