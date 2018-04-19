# IMPORTANT: This file is EXPERIMENTAL feature of Peatio 1.7. Don't ever try to use it in production.
# Specifications are available in docs/specs/event_api.md.

require 'active_support/concern'
require 'active_support/lazy_load_hooks'

module EventAPI
  class << self
    def notify(event_name, event_payload)
      arguments = [event_name, event_payload]
      middlewares.each do |middleware|
        returned_value = middleware.call(*arguments)
        case returned_value
          when Array then arguments = returned_value
          else return returned_value
        end
      rescue StandardError => e
        report_exception(e)
        raise
      end
    end

    def middlewares=(list)
      @middlewares = list
    end

    def middlewares
      @middlewares ||= []
    end
  end

  module ActiveRecord
    class Mediator
      attr_reader :record

      def initialize(record)
        @record = record
      end

      def notify(partial_event_name, event_payload)
        tokens = ['model']
        tokens << record.class.event_api_settings.fetch(:prefix) { record.class.name.underscore.gsub(/\//, '_') }
        tokens << partial_event_name.to_s
        full_event_name = tokens.join('.')
        EventAPI.notify(full_event_name, event_payload)
      end

      def notify_record_created
        notify(:created, record: record.as_json_for_event_api.compact)
      end

      def notify_record_updated
        current_record  = record
        previous_record = record.dup
        record.previous_changes.each { |attribute, values| previous_record.send("#{attribute}=", values.first) }

        previous_record.created_at ||= current_record.created_at

        before = previous_record.as_json_for_event_api.compact
        after  = current_record.as_json_for_event_api.compact

        notify :updated, \
          record:  after,
          changes: before.delete_if { |attribute, value| after[attribute] == value }
      end
    end

    module Extension
      extend ActiveSupport::Concern

      included do
        # We add «after_commit» callbacks immediately after inclusion.
        %i[create update].each do |event|
          after_commit on: event, prepend: true do
            if self.class.event_api_settings[:on]&.include?(event)
              event_api.public_send("notify_record_#{event}d")
            end
          end
        end
      end

      module ClassMethods
        def acts_as_eventable(settings = {})
          settings[:on] = %i[create update] unless settings.key?(:on)
          @event_api_settings = event_api_settings.merge(settings)
        end

        def event_api_settings
          @event_api_settings || superclass.instance_variable_get(:@event_api_settings) || {}
        end
      end

      def event_api
        @event_api ||= Mediator.new(self)
      end

      def as_json_for_event_api
        as_json
      end
    end
  end

  # To continue processing by further middlewares return array with event name and payload.
  # To stop processing event return any value which isn't an array.
  module Middlewares
    class IncludeEventMetadata
      def call(event_name, event_payload)
        event_payload[:name] = event_name
        [event_name, event_payload]
      end
    end

    class GenerateJWT
      def call(event_name, event_payload)
        [event_name, event_payload]
      end
    end

    class PrintToScreen
      def call(event_name, event_payload)
        Rails.logger.debug do
          ['',
           'Produced new event at ' + Time.current.to_s + ': ',
           'name    = ' + event_name,
           'payload = ' + event_payload.to_json,
           ''].join("\n")
        end
        [event_name, event_payload]
      end
    end

    class PublishToAbstractRabbitMQ
      def call(event_name, event_payload)
        Rails.logger.debug do
          ['',
           'Published new message to RabbitMQ (abstractly):',
           'exchange    = ' + exchange_name(event_name),
           'routing key = ' + routing_key(event_name),
           'payload     = ' + event_payload.to_json,
           ''
          ].join("\n")
        end
        [event_name, event_payload]
      end

    private

      # TODO: Validate that key include event category.
      def exchange_name(event_name)
        "peatio.events.#{event_name.split('.').first}"
      end

      def routing_key(event_name)
        event_name.split('.').drop(1).join('.')
      end
    end
  end

  middlewares << Middlewares::IncludeEventMetadata.new
  middlewares << Middlewares::GenerateJWT.new
  middlewares << Middlewares::PrintToScreen.new
  middlewares << Middlewares::PublishToAbstractRabbitMQ.new
end

ActiveSupport.on_load(:active_record) { ActiveRecord::Base.include EventAPI::ActiveRecord::Extension }
