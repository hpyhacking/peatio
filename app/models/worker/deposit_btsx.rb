module Worker
  class DepositBtsx

    BLOCK_DURATION = 10

    def initialize
      @rpc = CoinRPC['btsx']

      @last_block_num = ENV['BLOCK_NUM'].to_i
      if @last_block_num < 1
        tx = @rpc.last_deposit_account_transaction
        @last_block_num = tx['block_num'] if tx
      end
    end

    def process
      get_new_transactions.each do |block|
        Rails.logger.info block.inspect
      end
    end

    private

    def get_new_transactions
      txs = @rpc.get_deposit_transactions(@last_block_num+1)
      @last_block_num = txs.last['block_num'] unless txs.empty?
      txs
    end

  end
end
