# frozen_string_literal: true

module Peatio
  class App
    include ActiveSupport::Configurable

    class Error < ::StandardError; end

    class << self
      def define
        yield self
      end

      def set(key, default = nil, options = {})
        value = fetch!(key, default)

        validate!(key, value, options)
        value = type!(key, value, options)

        config[key] = value
      end

      def write(key, value)
        config[key] = value
      end

      private

      def fetch!(key, default)
        if env(key)
          return env(key)

        elsif Rails.application.credentials[key]
          return Rails.application.credentials[key]

        elsif !default.nil?
          return default

        else
          raise Error, "Config #{key} missing" if default.nil?
        end
      end

      def env(key)
        ENV['PEATIO_' + key.to_s.upcase]
      end

      def validate!(key, value, options)
        regex!(key, value, options[:regex]) if options[:regex]
        values!(key, value, options[:values]) if options[:values]
      end

      def type!(key, value, options)
        return value unless options[:type]

        case options[:type]
        when :array
          return value.split(',').map { |v| v.squish }
        when :bool
          values!(key, value, %w(true false))
          return value == 'true'
        when :integer
          regex!(key, value,  /^\d+$/)
          return value.to_i
        when :path
          return Rails.root.join(value).tap { |p| path!(key, p) }
        when :regexp
          return Regexp.new value
        end
      end

      def path!(key, path)
        unless File.exists?(path)
          raise Error.new("#{key.to_s.upcase} path is invalid #{path.to_s}")
        end
      end

      def regex!(key, value, regex)
        unless regex =~ value
          raise Error.new("#{key.to_s.upcase} does not match regex #{regex.inspect}")
        end
      end

      def values!(key, value, values)
        unless values.include?(value)
          raise Error.new("#{key.to_s.upcase} invalid, enabled values: #{values.to_s}")
        end
      end
    end
  end
end
