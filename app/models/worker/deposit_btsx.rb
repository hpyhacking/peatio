module Worker
  class DepositBtsx

    BLOCK_DURATION = 10

    def initialize
      @rpc = CoinRPC['btsx']

      @last_block_num = ENV['BLOCK_NUM'].to_i
      @last_block_num = @rpc.last_block.first['block_num'] if @last_block_num < 1
    end

    def process
      get_new_blocks(@last_block_num).each do |block|
        Rails.logger.info block.inspect
      end
    end

    private

    BLOCK_LIMIT = 50
    def get_new_blocks(from)
      blocks = @rpc.blockchain_list_blocks 0, -BLOCK_LIMIT

      if blocks.blank?
        Rails.logger.warn "No blocks found!"
        return []
      end

      return [] if blocks.first['block_num'] <= @last_block_num

      new_blocks = blocks.select{|block| block['block_num'] > @last_block_num }.reverse

      @last_block_num = new_blocks.last['block_num']
      new_blocks
    end

  end
end
