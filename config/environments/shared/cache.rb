# encoding: UTF-8
# frozen_string_literal: true

Rails.application.configure do
  if ENV.true?("REDIS_CLUSTER")
    config.cache_store = :redis_cache_store, { driver: :hiredis, cluster: [ENV.fetch('REDIS_URL')], password: ENV.fetch('REDIS_PASSWORD') }
  else
    config.cache_store = :redis_cache_store, { driver: :hiredis, url: ENV.fetch('REDIS_URL') }
  end
end
