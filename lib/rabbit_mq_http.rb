class RabbitMQHTTP
  class << self
    def default_client
      new(default_options)
    end

    def default_options
      { scheme:   :http,
        host:     ENV.fetch('RABBITMQ_HOST', 'localhost'),
        port:     15672,
        path:     '/api',
        user:     ENV.fetch('RABBITMQ_USER', 'guest'),
        password: ENV.fetch('RABBITMQ_PASSWORD', 'guest') }
    end
  end

  def initialize(options)
    url = ::URI::HTTP.build(options.slice(:scheme, :host, :port, :path))

    @connection = Faraday.new(url) do |conn|
      conn.basic_auth options.fetch(:user), options.fetch(:password)
      conn.adapter Faraday.default_adapter
    end
  end

  def list_queues
    response = @connection.get('queues')
    JSON.parse(response.body).map(&:symbolize_keys)
  end
end
