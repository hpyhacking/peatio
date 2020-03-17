# frozen_string_literal: true

module Peatio
  module Upstream
    class Opendax < Peatio::Upstream::Base
      def initialize(config)
        super
        @connection = Faraday.new(url: "#{config['rest']}") do |builder|
          builder.response :json
          builder.response :logger if config["debug"]
          builder.adapter(@adapter)
          builder.ssl[:verify] = config["verify_ssl"] unless config["verify_ssl"].nil?
        end
        @rest = "#{config['rest']}"
        @ws_url = "#{config['websocket']}/public"
      end

      def ws_read_public_message(msg)
        if msg.keys.first.split('.').second == 'trades'
          detect_trade(msg)
        end
      end

      def detect_trade(msg)
        msg.values.first['trades'].each do |trade|
          notify_public_trade(trade)
        end
      end

      def subscribe_trades(market, ws)
        sub = {
          event: 'subscribe',
          streams: ["#{market}.trades"]
        }
        Rails.logger.info 'Open event' + sub.to_s
        EM.next_tick do
          ws.send(JSON.generate(sub))
        end
      end
    end
  end
end
