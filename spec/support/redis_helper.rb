# encoding: UTF-8
# frozen_string_literal: true

module RedisTestHelper
  def clear_redis
    Rails.cache.instance_variable_get(:@data).flushall
  end
end

RSpec.configure { |config| config.include RedisTestHelper }
