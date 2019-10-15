# encoding: UTF-8
# frozen_string_literal: true

Rails.application.configure do
  config.cache_store = :redis_cache_store, { driver: :hiredis, url: ENV.fetch('REDIS_URL') }
end
