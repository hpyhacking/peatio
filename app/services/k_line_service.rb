# encoding: UTF-8
# frozen_string_literal: true

require 'peatio/influxdb'
class KLineService
  POINT_PERIOD_IN_SECONDS = 60

  # Point period units are calculated in POINT_PERIOD_IN_SECONDS.
  # It means that period with value 5 is equal to 5 minutes (5 * POINT_PERIOD_IN_SECONDS = 300).
  AVAILABLE_POINT_PERIODS = [1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10_080].freeze

  AVAILABLE_POINT_LIMITS  = (1..10_000).freeze

  HUMANIZED_POINT_PERIODS = {
    1 => '1m', 5 => '5m', 15 => '15m', 30 => '30m',                   # minutes
    60 => '1h', 120 => '2h', 240 => '4h', 360 => '6h', 720 => '12h',  # hours
    1440 => '1d', 4320 => '3d',                                       # days
    10_080 => '1w'                                                    # weeks
  }.freeze

  class << self
    def [](market, period)
      services[[market, period]] ||= new(market, period)
    end

    def services
      @services ||= {}
    end
  end


  attr_accessor :market_id, :period

  def initialize(marked_id, period)
    @market_id = marked_id
    @period    = humanize_period(period)
  end

  # OHCL - open, high, closing, and low prices.
  def get_ohlc(options = {})
    options = options.symbolize_keys.tap do |o|
      o.delete(:limit) if o[:time_from].present? && o[:time_to].present?
    end

    time_from = options[:time_from]
    time_to = options[:time_to]
    offset = calculate_offset(options) if time_from.blank?

    q = ["SELECT * FROM candles_#{@period} WHERE market='#{@market_id}'"]
    q << "AND time >= #{time_from.to_i * 1_000_000_000}" if time_from.present?
    q << "AND time <= #{time_to.to_i * 1_000_000_000}" if time_to.present?
    q << "ORDER BY #{options[:order_by]}" if options[:order_by]
    q << "LIMIT #{options[:limit]}" if options[:limit]
    q << "OFFSET #{offset}" if offset.present? && options[:offset]

    Peatio::InfluxDB.client(keyshard: @market_id, epoch: 's').query(q.join(' ')) do |_name, _tags, points|
      return points.map do |point|
        [point['time'], point['open'], point['high'], point['low'], point['close'], point['volume']]
      end
    end
  end

  def calculate_offset(options)
    q = ["SELECT COUNT(high) FROM candles_#{@period} WHERE market='#{@market_id}'"]
    q << "AND time <= #{options[:time_to].to_i * 1_000_000_000}" if options[:time_to].present?
    Peatio::InfluxDB.client(keyshard: @market_id, epoch: 's').query(q.join(' ')) do |_, _, values|
      return options[:limit].to_i < values.first['count'] ? values.first['count'] - options[:limit] : 0
    end
  end

  def event_name(period)
    "kline-#{humanize_period(period)}"
  end

  def humanize_period(period)
    HUMANIZED_POINT_PERIODS.fetch(period) do
      raise StandardError, "Not available period #{period}"
    end
  end
end
