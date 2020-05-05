# frozen_string_literal: true

require 'vault'

module Vault
  # Vault::TOTP helper
  module TOTP
    Error = Class.new(StandardError)

    class << self

      def server_available?
        read_data('sys/health').present?
      rescue StandardError
        false
      end

      def validate?(uid, code)
        write_data(totp_code_key(uid), code: code).data[:valid]
      end

      def with_human_error
        raise ArgumentError, 'Block is required' unless block_given?
        yield
      rescue Vault::VaultError => e
        ::Rails.logger.error { e }
        if e.message.include?('connection refused')
          raise Error, '2FA server is under maintenance'
        end

        if e.message.include?('code already used')
          raise Error, 'This code was already used. Wait until the next time period'
        end

        raise e
      end

      private

      def totp_code_key(uid)
        "totp/code/#{Vault.application}_#{uid}"
      end

      def read_data(key)
        with_human_error do
          vault.read(key)
        end
      end

      def write_data(key, params)
        with_human_error do
          vault.write(key, params)
        end
      end

      def vault
        Vault.logical
      end
    end
  end
end
