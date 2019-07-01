# frozen_string_literal: true

# TODO: Add Bench::Error and better errors processing.
# TODO: Add Bench::Report and extract all metrics to it.
module Bench
  module OrderProcessing
    class Direct
      include Helpers

      def initialize(config)
        @config = config

        @injector = Injectors.initialize_injector(@config[:orders])
        @currencies = Currency.where(id: @config[:currencies].split(',').map(&:squish).reject(&:blank?))
        @order_processor = Workers::AMQP::OrderProcessor.new
        # TODO: Print errors in the end of benchmark and include them into report.
        @errors = []
      end

      def run!
        Kernel.puts "Creating members ..."
        @members = Factories.create_list(:member, @config[:traders])

        Kernel.puts "Depositing funds ..."
        @members.map(&method(:become_billionaire))

        Kernel.puts "Generating orders by injector and saving them in db..."
        # TODO: Add orders generation progress bar.
        @injector.generate!(@members)

        @orders_number = @injector.size

        @processing_started_at =  Time.now

        process_orders

        @processing_finished_at = Time.now
      end

      def process_orders
        loop do
          order = @injector.pop
          break unless order

          @order_processor.process({action: 'cancel', order: order.to_matching_attributes}.deep_stringify_keys!)
        rescue StandardError => e
          Kernel.puts e
          @errors << e
        end
      end

      # TODO: Add more useful metrics to result.
      def result
        @result ||=
        begin
          processing_ops = @orders_number / (@processing_finished_at - @processing_started_at)

          # TODO: Deal with calling iso8601(6) everywhere.
          { config: @config,
            order_processing: {
              started_at:  @processing_started_at.iso8601(6),
              finished_at: @processing_finished_at.iso8601(6),
              operations:  @orders_number,
              ops:         processing_ops
            }
          }
        end
      end

      def save_report
        report_path = Rails.root.join(@config[:report_path])
        FileUtils.mkpath(report_path)
        report_name = "#{self.class.parent.name.demodulize.downcase}-"\
                      "#{self.class.name.humanize.demodulize}-#{@config[:orders][:injector]}-"\
                      "#{@config[:orders][:number]}-#{@processing_started_at.iso8601}.yml"
        File.open(report_path.join(report_name), 'w') do |f|
          f.puts YAML.dump(result.deep_stringify_keys)
        end
      end
    end
  end
end
