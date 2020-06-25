# encoding: UTF-8
# frozen_string_literal: true

module Peatio
  module InfluxDB
    class << self
      def client(opts={})
        # Map InfluxDB clients with received opts.
        clients[opts] ||= ::InfluxDB::Client.new(parse(config.merge(opts)))
      end

      def config
        yaml = ::Pathname.new("config/influxdb.yml")
        return {} unless yaml.exist?

        erb = ::ERB.new(yaml.read)
        ::SafeYAML.load(erb.result)[ENV.fetch('RAILS_ENV', 'development')].symbolize_keys || {}
      end

      def clients
        @clients ||= {}
      end

      def parse(configs)
        hosts = configs[:host]
        configs[:host] = hosts[Zlib::crc32(configs[:keyshard].to_s) % hosts.count]
        configs
      end
    end
  end
end
