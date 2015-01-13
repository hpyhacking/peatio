module Middleware
  class Security

    def initialize(app)
      @app = app
    end

    def call(env)
      env['HTTP_HOST'] = host
      env['HTTP_X_FORWARDED_HOST'] = host
      @app.call(env)
    end

    def host
      @host ||= ENV['URL_PORT'] ? "#{ENV['URL_HOST']}:#{ENV['URL_PORT']}" : ENV['URL_HOST']
    end

  end
end
