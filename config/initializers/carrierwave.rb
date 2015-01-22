CarrierWave.configure do |config|
  config.storage = :file
  config.cache_dir = "#{Rails.root}/tmp/uploads"
end
