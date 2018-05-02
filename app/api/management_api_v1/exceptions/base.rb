module ManagementAPIv1
  module Exceptions
    class Base < StandardError
      def initialize(message:, **options)
        @options = options
        super(message)
      end

      def debug_message
        @options[:debug_message]
      end

      def headers
        @options.fetch(:headers, {})
      end

      def status
        @options.fetch(:status)
      end
    end
  end
end
