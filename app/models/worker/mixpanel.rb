require 'thread/pool'

module Worker
  class Mixpanel

    def initialize
      size = ENV['MIXPANEL_POOL'].to_i
      raise "Invalid pool size!" if size <= 0

      @pool     = Thread.pool size
      @consumer = ::Mixpanel::Consumer.new
    end

    def process(payload, metadata, delivery_info)
      @pool.process { @consumer.send *payload }
    end

  end
end
