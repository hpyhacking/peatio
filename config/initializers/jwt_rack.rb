# encoding: UTF-8
# frozen_string_literal: true

# Require JWT initializer to configure JWT key & options.
require_relative 'jwt'
require 'jwt/rack'

on_error = lambda do |_error|
  message = 'jwt.decode_and_verify'
  body    = { errors: [message] }.to_json
  headers = { 'Content-Type' => 'application/json', 'Content-Length' => body.bytesize.to_s }

  [401, headers, [body]]
end

# TODO: Fixme in jwt-rack handle api/v2// as api/v2.
auth_args = {
  secret:   Rails.configuration.x.jwt_public_key,
  options:  Rails.configuration.x.jwt_options,
  verify:   Rails.configuration.x.jwt_public_key.present?,
  exclude:  %w(/api/v2/public /api/v2//public /api/v2/management /api/v2//management
               /api/v2/swagger /api/v2//swagger /api/v2/admin/swagger /api/v2//admin/swagger
               /api/v2/coinmarketcap /api/v2//coinmarketcap /api/v2/coingecko /api/v2//coingecko),
  on_error: on_error
}

Rails.application.config.middleware.use JWT::Rack::Auth, auth_args
