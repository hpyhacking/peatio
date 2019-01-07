# encoding: UTF-8
# frozen_string_literal: true

require 'vault/totp'

Vault.configure do |config|
  config.address = ENV.fetch('VAULT_URL', 'http://127.0.0.1:8200')
  config.token = ENV.fetch('VAULT_TOKEN')
  config.ssl_verify = false
  config.timeout = 60
end
