module Vault
  module Rails
    module Configurable
      include Vault::Configurable

      # The name of the Vault::Rails application.
      #
      # @raise [RuntimeError]
      #   if the application has not been set
      #
      # @return [String]
      def application
        if defined?(@application) && !@application.nil?
          return @application
        end
        if ENV.has_key?("VAULT_RAILS_APPLICATION")
          return ENV["VAULT_RAILS_APPLICATION"]
        end
        raise RuntimeError, "Must set `Vault::Rails#application'!"
      end

      # Set the name of the application.
      #
      # @param [String] val
      def application=(val)
        @application = val
      end

      # Whether the connection to Vault is enabled. The default value is `false`,
      # which means vault-rails will perform in-memory encryption/decryption and
      # not attempt to talk to a real Vault server. This is useful for
      # development and testing.
      #
      # @return [true, false]
      def enabled?
        if defined?(@enabled) && !@enabled.nil?
          return @enabled
        end
        if ENV.has_key?("VAULT_RAILS_ENABLED")
          return (ENV["VAULT_RAILS_ENABLED"] == "true")
        end
        return false
      end

      # Sets whether Vault is enabled. Users can set this in an initializer
      # depending on their Rails environment.
      #
      # @example
      #   Vault.configure do |vault|
      #     vault.enabled = Rails.env.production?
      #   end
      #
      # @return [true, false]
      def enabled=(val)
        @enabled = !!val
      end

      # Whether warnings about in-memory ciphers are enabled. The default value
      # is `true`, which means vault-rails will log a warning for every attempt
      # to encrypt or decrypt using an in-memory cipher. This is useful for
      # development and testing.
      #
      # @return [true, false]
      def in_memory_warnings_enabled?
        if !defined?(@in_memory_warnings_enabled) || @in_memory_warnings_enabled.nil?
          return true
        end
        return @in_memory_warnings_enabled
      end

      # Sets whether warnings about in-memory ciphers are enabled. Users can set
      # this in an initializer depending on their Rails environment.
      #
      # @example
      #   Vault.configure do |vault|
      #     vault.in_memory_warnings_enabled = !Rails.env.test?
      #   end
      #
      # @return [true, false]
      def in_memory_warnings_enabled=(val)
        @in_memory_warnings_enabled = val
      end

      # Gets the number of retry attempts.
      #
      # @return [Fixnum]
      def retry_attempts
        @retry_attempts ||= 0
      end

      # Sets the number of retry attempts. Please see the Vault documentation
      # for more information.
      #
      # @param [Fixnum] val
      def retry_attempts=(val)
        @retry_attempts = val
      end

      # Gets the number of retry attempts.
      #
      # @return [Fixnum]
      def retry_base
        @retry_base ||= Vault::Defaults::RETRY_BASE
      end

      # Sets the retry interval. Please see the Vault documentation for more
      # information.
      #
      # @param [Fixnum] val
      def retry_base=(val)
        @retry_base = val
      end

      # Gets the retry maximum wait.
      #
      # @return [Fixnum]
      def retry_max_wait
        @retry_max_wait ||= Vault::Defaults::RETRY_MAX_WAIT
      end

      # Sets the maximum amount of time for a single retry. Please see the Vault
      # documentation for more information.
      #
      # @param [Fixnum] val
      def retry_max_wait=(val)
        @retry_max_wait = val
      end

      # Gets the default role name.
      #
      # @return [String]
      def default_role_name
        @default_role_name
      end

      # Sets the default role to use with various plugins.
      #
      # @param [String] val
      def default_role_name=(val)
        @default_role_name = val
      end
    end
  end
end
