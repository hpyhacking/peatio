module Vault
  module Rails
    module JSONSerializer
      DECODE_OPTIONS = {
        max_nested:       false,
        create_additions: false,
      }.freeze

      def self.encode(raw)
        _init!

        JSON.fast_generate(raw)
      end

      def self.decode(raw)
        _init!

        return nil if raw == nil || raw == ""

        JSON.parse(raw, DECODE_OPTIONS)
      end

      protected

      def self._init!
        return if defined?(@_init)
        require "json"
        @_init = true
      end
    end
  end
end
