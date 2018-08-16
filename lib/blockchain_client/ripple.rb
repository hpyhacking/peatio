# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Ripple < Base

    def inspect_address!(address)
      { address:  normalize_address(address),
        is_valid: address?(normalize_address(address)) }
    end

    protected

    def address?(address)
      /\Ar[0-9a-zA-Z]{33}(:?\?dt=[1-9]\d*)?\z/.match?(address)
    end

  end
end
