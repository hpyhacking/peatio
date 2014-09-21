module Worker
  class DepositBtsx < DepositCoin

    BLOCK_DURATION = 10

    def initialize
      @rpc = CoinRPC['btsx']

      @last_block_num = ENV['BLOCK_NUM'].to_i
      if @last_block_num < 1
        tx = @rpc.last_deposit_account_transaction
        @last_block_num = tx['block_num'] if tx
      end

      @currency = Currency.find_by_code 'btsx'
      @channel  = DepositChannel.find_by_key 'bitsharesx'
    end

    def process
      get_new_transactions.each do |raw|
        block      = raw['block_num']
        txid       = raw['trx_id']
        entry      = raw['ledger_entries'].first
        amount     = @rpc.fmt_amount entry['amount']['amount']
        fee        = @rpc.fmt_amount raw['fee']['amount']
        address    = "#{@currency.deposit_account}|#{entry['memo']}"
        receive_at = Time.zone.parse raw['timestamp']

        Rails.logger.info "NEW - block: #{block} id: #{txid}"

        ActiveRecord::Base.transaction do
          return if PaymentTransaction::Btsx.find_by_txid(txid)

          deposit(txid, address, amount, block, receive_at, @channel)
        end
      end
    end

    def deposit(txid, address, amount, confirmations, receive_at, channel)
      tx = PaymentTransaction::Btsx.create!(
        txid: txid,
        address: address,
        amount: amount,
        confirmations: confirmations,
        receive_at: receive_at,
        currency: channel.currency
      )

      if tx.account && tx.member
        deposit = channel.kls.create!(
          txid: tx.txid,
          amount: tx.amount,
          member: tx.member,
          account: tx.account,
          currency: tx.currency,
          memo: tx.confirmations
        )

        deposit.submit!
        tx.confirm!
      else
        Rails.logger.info "Transaction##{txid} missing memo, PaymentTransaction##{tx.id} failed to deposit."
        nil
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
