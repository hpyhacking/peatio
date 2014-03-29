require 'net/http'
require 'uri'
require 'json'

class CoinRPC
  def initialize(uri)
    @uri = URI.parse(uri)
  end

  def self.[](currency)
    url = Currency.find_by_code(currency).rpc
    url ? self.new(url) : nil
  end

  def safe_getbalance
    begin
      getbalance
    rescue
      'N/A'
    end
  end

  def method_missing(name, *args)
    post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
    resp = JSON.parse( http_post_request(post_body) )
    raise JSONRPCError, resp['error'] if resp['error']
    result = resp['result']
    result.symbolize_keys! if result.is_a? Hash
    result
  end

  def http_post_request(post_body)
    http    = Net::HTTP.new(@uri.host, @uri.port)
    request = Net::HTTP::Post.new(@uri.request_uri)
    request.basic_auth @uri.user, @uri.password
    request.content_type = 'application/json'
    request.body = post_body
    http.request(request).body
  rescue Errno::ECONNREFUSED => e
    raise ConnectionRefusedError
  end

  class JSONRPCError < RuntimeError; end
  class ConnectionRefusedError < StandardError
  end
end
