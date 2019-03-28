# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Dash < Bitcoin

    def get_block(block_hash)
      json_rpc(:getblock, [block_hash, true]).fetch('result')
    end

    def get_unconfirmed_txns
      json_rpc(:getrawmempool).fetch('result')
    end
  end
end
