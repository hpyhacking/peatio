# frozen_string_literal: true

class CoinMarketCap
  Error = Class.new(StandardError)

  class << self
    def default_client
      new(default_options)
    end

    def default_options
      {
        host:   ENV.fetch('CMC_HOST','pro-api.coinmarketcap.com'),
        path:   '/v1/cryptocurrency/map',
        query:  {
          CMC_PRO_API_KEY: 'UNIFIED-CRYPTOASSET-INDEX',
          listing_status:  'active'
        }.to_query
      }
    end
  end

  def initialize(options)
    url = ::URI::HTTPS.build(options.slice(:host, :path, :query))

    @connection = Faraday.new(url) do |conn|
      conn.response :raise_error
      conn.adapter Faraday.default_adapter
    end
  end

  def get(params={})
    response = @connection.get do |req|
      req.params = @connection.params.merge(params.as_json)
    end

    JSON(response.body).deep_symbolize_keys.yield_self do |body|
      # Error code will be equal to zero if there is no error
      raise Error, body[:status][:error_message] if body[:status][:error_code].nonzero? || body[:data].blank?
      body[:data]
    end
  end
end
