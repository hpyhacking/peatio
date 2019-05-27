module Bitcoin
  class Client
    Error = Class.new(StandardError)
    class ConnectionError < Error; end

    class ResponseError < Error
      def initialize(code, msg)
        @code = code
        @msg = msg
      end

      def message
        "#{@msg} (#{@code})"
      end
    end

    extend Memoist

    def initialize(endpoint)
      @json_rpc_endpoint = URI.parse(endpoint)
    end

    def json_rpc(method, params = [])
      response = connection.post \
        '/',
        { jsonrpc: '1.0', method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise ResponseError.new(error['code'], error['message']) if error }
      response.fetch('result')
    rescue => e
      if e.is_a?(Error)
        raise e
      elsif e.is_a?(Faraday::Error)
        raise ConnectionError, e
      else
        raise Error, e
      end
    end

    private

    def connection
      Faraday.new(@json_rpc_endpoint).tap do |connection|
        unless @json_rpc_endpoint.user.blank?
          connection.basic_auth(@json_rpc_endpoint.user, @json_rpc_endpoint.password)
        end
      end
    end
    memoize :connection
  end
end
