# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Litecoin < Bitcoin

    def latest_block_number
      Rails.cache.fetch :latest_litecoin_block_number, expires_in: 5.seconds do
        json_rpc(:getblockcount).fetch('result')
      end
    end

  end
end
