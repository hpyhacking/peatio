# frozen_string_literal: true

# TODO: Add Bench::Error and better errors processing.
# TODO: Add Bench::Report and extract all metrics to it.
module Bench
  module Matching
    class AMQP
      include Helpers

      def initialize(config)
        @config = config

        @rmq_http_client = RabbitMQHTTP.default_client

        @injector = Injectors.initialize_injector(@config[:orders])
        @currencies = Currency.where(id: @config[:currencies].split(',').map(&:squish).reject(&:blank?))
        # TODO: Print errors in the end of benchmark and include them into report.
        @errors = []
      end

      def run!
        # TODO: Check if Matching daemon is running before start (use queue_info[:consumers]).
        Kernel.puts "Creating members ..."
        @members = Factories.create_list(:member, @config[:traders])

        Kernel.puts "Depositing funds ..."
        @members.map(&method(:become_billionaire))

        Kernel.puts "Generating orders by injector and saving them in db..."
        # TODO: Add orders generation progress bar.
        @injector.generate!(@members)

        @orders_number = @injector.size

        Kernel.puts "Publishing messages to RabbitMQ..."
        @matching_started_at = @publish_started_at = Time.now
        # TODO: Add orders publishing progress bar.
        publish_messages

        @publish_finished_at = Time.now
        Kernel.puts "Messages are published to RabbitMQ."

        Kernel.puts "Waiting for order processing by matching daemon..."
        wait_for_matching
        @matching_finished_at = Time.now
      end

      def publish_messages
        Array.new(@config[:threads]) do
          Thread.new do
            loop do
              order = @injector.pop
              break unless order
              AMQP::Queue.enqueue(:matching, action: 'submit', order: order.to_matching_attributes)
            rescue StandardError => e
              Kernel.puts e
              @errors << e
            end
          end
        end.map(&:join)
      end

      # TODO: Find better solution for getting message number in queue.
      # E.g there is rabbitmqctl list_queues.
      def wait_for_matching
        last_log_time = Time.at(0)
        queue_status_file = File.open(queue_status_file_path('matching'), 'a')

        loop do
          queue_status = matching_queue_status
          break if queue_status[:messages].zero? &&
                  queue_status[:idle_since].present? &&
                  Time.parse("#{queue_status[:idle_since]} UTC") >= @publish_started_at

          if last_log_time + 5 < Time.now
            queue_status_file.puts(YAML.dump([queue_status.merge(timestamp: Time.now.iso8601).deep_stringify_keys]))
            last_log_time = Time.now
          end

          sleep 0.5
        end
      end

      # TODO: Add more useful metrics to result.
      def result
        @result ||=
        begin
          publish_ops =  @orders_number / (@publish_finished_at - @publish_started_at)
          matching_ops = @orders_number / (@matching_finished_at - @publish_started_at)

          # TODO: Deal with calling iso8601(6) everywhere.
          { config: @config,
            submit_publish: {
              started_at:  @publish_started_at.iso8601(6),
              finished_at: @publish_started_at.iso8601(6),
              operations:  @orders_number,
              ops:         publish_ops
            },
            matching: {
              started_at:  @matching_started_at.iso8601(6),
              finished_at: @matching_finished_at.iso8601(6),
              operations:  @orders_number,
              ops:         matching_ops
            }
          }
        end
      end

      def save_report
        report_path = Rails.root.join(@config[:report_path])
        FileUtils.mkpath(report_path)
        report_name = "#{self.class.parent.name.demodulize.downcase}-"\
                      "#{self.class.name.humanize.demodulize}-#{@config[:orders][:injector]}-"\
                      "#{@config[:orders][:number]}-#{@publish_started_at.iso8601}.yml"
        File.open(report_path.join(report_name), 'w') do |f|
          f.puts YAML.dump(result.deep_stringify_keys)
        end
      end

      private
      # TODO: Use get queue by name.
      # TODO: Use Faraday instead of RabbitMQ::HTTP::Client.
      def matching_queue_status
        @rmq_http_client.list_queues.find { |q| q[:name] == AMQP::Config.binding_queue(:matching).first }
      end

      def queue_status_file_path(name)
        log_path = Rails.root.join(@config[:log_path])
        FileUtils.mkpath(log_path)
        log_path.join("#{name}-#{@publish_started_at.iso8601}.yml")
      end
    end
  end
end
