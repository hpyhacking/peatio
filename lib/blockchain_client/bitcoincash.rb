# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Bitcoincash < Bitcoin

    def get_block(block_hash)
      json_rpc(:getblock, [block_hash, true]).fetch('result')
    end

    def normalize_address(address)
      CashAddr::Converter.to_cash_address(super)
    end

    # IMPORTANT: Be sure to set the correct value!
    def supports_cash_addr_format?
      true
    end

    def get_unconfirmed_txns
      json_rpc(:getrawmempool).fetch('result')
    end
  end
end
