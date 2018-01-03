module CoinRPC
  class BTC < BaseRPC
    def handle(name, *args)
      post_body = { method: name, params: args, id: 'jsonrpc' }.to_json
      resp = JSON.parse(http_post_request(post_body))

      raise JSONRPCError, resp['error'] if resp['error']

      result = resp['result']
      result.is_a?(Hash) ? result.symbolize_keys : result
    end

    def http_post_request(post_body)
      http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Post.new(@uri.request_uri)

      request.basic_auth @uri.user, @uri.password
      request.content_type = 'application/json'
      request.body = post_body

      http.request(request).body
    rescue Errno::ECONNREFUSED
      raise ConnectionRefusedError
    end

    def safe_getbalance
      getbalance || 'N/A'
    end
  end
end
