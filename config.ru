# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment', __FILE__)
require 'rack/cors'

map Rails.application.config.relative_url_root do
  use Rack::Cors do
    allow do
      origins CORS::Validations.validate_origins(ENV['API_CORS_ORIGINS'])
      resource '/api/*',
        methods: %i[get post delete put patch options head],
        headers: :any,
        credentials: ENV.true?('API_CORS_ALLOW_CREDENTIALS'),
        max_age: CORS::Validations.validate_max_age(ENV['API_CORS_MAX_AGE'])
    end
  end
  run Rails.application
end
