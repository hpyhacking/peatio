# frozen_string_literal: true

module Workers
  module Daemons
    class Upstream < Base
      def run
        Engine.all.map { |e| Thread.new { process(e) } }.map(&:join)
      end

      def process(engine)
        EM.synchrony do
          upstream = Peatio::Upstream.registry[engine.driver]
          engine.markets.each do |market|
            target = if market.data.present? && market.data['target'].present?
                       market.data['target']
                     else
                       market.id
                     end

            configs = engine.data.merge('source' => market.id, 'amqp' => ::AMQP::Queue, 'target' => target)

            upstream.new(configs).ws_connect
            Rails.logger.info "Upstream with driver #{engine.driver} for #{market.id} started"
          rescue StandardError => e
            report_exception(e)
            next
          end
        rescue Peatio::AdapterRegistry::NotRegisteredAdapterError => e
          report_exception(e)
        end
      end

      def stop
        puts 'Shutting down'
        @shutdown = true
        exit(42)
      end
    end
  end
end
