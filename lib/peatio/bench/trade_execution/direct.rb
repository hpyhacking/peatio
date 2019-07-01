# frozen_string_literal: true

module Bench
  module TradeExecution
    class Direct
      include Helpers

      def initialize(config)
        @config = config
        raise "This benchmark doesn't support Bitfinex injector" if config[:orders][:injector] == 'bitfinex'

        @bid_injector = Injectors.initialize_injector(@config[:orders].merge(price: 1, side: 'OrderBid'))
        @ask_injector = Injectors.initialize_injector(@config[:orders].merge(price: 0.9, side: 'OrderAsk'))
        @currencies = Currency.where(id: @config[:currencies].split(',').map(&:squish).reject(&:blank?))
        @executor = Workers::AMQP::TradeExecutor.new
        # TODO: Print errors in the end of benchmark and include them into report.
        @errors = []
      end

      def run!
        Kernel.puts "Creating members ..."
        @members = Factories.create_list(:member, @config[:traders])

        Kernel.puts "Depositing funds ..."
        @members.map(&method(:become_billionaire))

        Kernel.puts "Generating orders by injector and saving them in db..."

        Kernel.puts 'Waiting for trades processing by trade execution daemon...'
        @bid_injector.generate!(@members)
        @ask_injector.generate!(@members)

        @execution_started_at = Time.now
        process_messages
        @execution_finished_at = Time.now
      end

      def process_messages
        loop do
          ask = @ask_injector.pop
          bid = @bid_injector.pop
          break unless ask && bid
          volume = ask.volume > bid.volume ? bid.volume : ask.volume
          @executor.process({ market_id: ask.market_id,
                              ask_id: ask.id,
                              bid_id: bid.id,
                              strike_price: ask.price,
                              volume: volume,
                              funds: volume * ask.price })
        rescue StandardError => e
          Kernel.puts e
          @errors << e
        end
      end

      def result
        @result ||=
          begin
            trades_number = Trade.where('created_at >= ?', @execution_started_at).length
            trades_ops = trades_number / (@execution_finished_at - @execution_started_at)

            { config: @config,
              trade_execution: {
                started_at:  @execution_started_at.iso8601(6),
                finished_at: @execution_finished_at.iso8601(6),
                operations:  trades_number,
                ops:         trades_ops
              }
            }
          end
      end

      def save_report
        report_path = Rails.root.join(@config[:report_path])
        FileUtils.mkpath(report_path)
        report_name = "#{self.class.parent.name.demodulize.downcase}-"\
                      "#{self.class.name.humanize.demodulize}-#{@config[:orders][:injector]}-"\
                      "#{@config[:orders][:number]}-#{@execution_started_at.iso8601}.yml"
        File.open(report_path.join(report_name), 'w') do |f|
          f.puts YAML.dump(result.deep_stringify_keys)
        end
      end
    end
  end
end
