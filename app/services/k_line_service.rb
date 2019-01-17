# encoding: UTF-8
# frozen_string_literal: true

class KLineService
  extend Memoist

  POINT_PERIOD_IN_SECONDS = 60.freeze

  # Point period units are calculated in POINT_PERIOD_IN_SECONDS.
  # It means that period with value 5 is equal to 5 minutes (5 * POINT_PERIOD_IN_SECONDS = 300).
  AVAILABLE_POINT_PERIODS = [1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080].freeze

  AVAILABLE_POINT_LIMITS  = (1..10000).freeze

  HUMANIZED_POINT_PERIODS = {
    1 => '1m', 5 => '5m', 15 => '15m', 30 => '30m',                   # minuets
    60 => '1h', 120 => '2h', 240 => '4h', 360 => '6h', 720 => '12h',  # hours
    1440 => '1d', 4320 => '3d',                                       # days
    10080 => '1w'                                                     # weeks
  }.freeze

  attr_accessor :market_id, :period

  def initialize(marked_id, period)
    @market_id = marked_id
    @period    = period
  end

  def redis
    Redis.new(
      url: ENV.fetch('REDIS_URL'),
      db:  1
    )
  end
  memoize :redis

  def key
    "peatio:#{market_id}:k:#{period}"
  end
  memoize :key

  class << self
    def humanize_period(period)
      HUMANIZED_POINT_PERIODS.fetch(period) do
        raise StandardError, "Not available period #{period}"
      end
    end
  end

  # OHCL - open, high, closing, and low prices.
  def get_ohlc(options={})
    options = options.symbolize_keys.tap do |o|
      o.delete(:limit) if o[:time_from].present? && o[:time_to].present?
    end

    return [] if first_timestamp.nil?

    left_index  = left_index_for(options)
    right_index = right_index_for(options)
    return [] if right_index < left_index

    JSON.parse('[%s]' % redis.lrange(key, left_index, right_index).join(','))
  end

  private

  def points_length
    redis.llen(key)
  end
  memoize :points_length

  def first_timestamp
    ts_json = redis.lindex(key, 0)
    ts_json.blank? ? nil : JSON.parse(ts_json).first
  end
  memoize :first_timestamp

  def index_for(timestamp)
    (timestamp - first_timestamp) / POINT_PERIOD_IN_SECONDS / period
  end

  def left_index_for(options)
    left_offsets = [0]

    if options[:time_from].present?
      left_offsets << index_for(options[:time_from])
    end

    if options[:limit].present?
      if options[:time_to].present?
        left_offsets << index_for(options[:time_to]) - options[:limit] + 1
      elsif options[:time_from].blank?
        left_offsets << points_length - options[:limit]
      end
    end
    left_offsets.max
  end

  def right_index_for(options)
    right_offsets = [points_length]

    if options[:time_to].present?
      right_offsets << index_for(options[:time_to])
    end

    if options[:limit].present? && options[:time_from].present?
      right_offsets << index_for(options[:time_from]) + options[:limit] - 1
    end
    right_offsets.min
  end
end
