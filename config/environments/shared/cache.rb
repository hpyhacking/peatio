Rails.application.configure do
  config.cache_store = :redis_store, ENV.fetch('REDIS_URL')
end
