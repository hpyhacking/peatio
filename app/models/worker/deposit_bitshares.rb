# Deposit worker for all bitshares_toolkit derivations.
module Worker
  class DepositBitshares < DepositCoin

    def initialize(code)
      @rpc      = CoinRPC[code]
      @currency = Currency.find_by_code code
      @channel  = DepositChannel.find_by_key @currency.key
      @pt_class = "PaymentTransaction::#{code.capitalize}".constantize

      tx = @rpc.last_deposit_account_transaction
      @last_block_num = tx['block_num']
    end

    def rescan(from, to)
      @rpc.get_deposit_transactions(from, to).each do |raw|
        if raw['block_num'] >= from && raw['block_num'] <= to
          process_transaction raw
        end
      end
    end

    def process
      get_new_transactions.each do |raw|
        process_transaction raw
      end
    end

    def process_transaction(raw)
      block      = raw['block_num']
      txid       = raw['trx_id']
      entry      = raw['ledger_entries'].first
      amount     = @rpc.fmt_amount entry['amount']['amount']
      fee        = @rpc.fmt_amount raw['fee']['amount']
      memo       = entry['memo']
      address    = "#{@currency.deposit_account}|#{memo}"
      payer      = entry['from_account']
      receive_at = Time.zone.parse raw['timestamp']

      Rails.logger.info "NEW - block: #{block} id: #{txid}"

      ActiveRecord::Base.transaction do
        if @pt_class.find_by_txid(txid)
          Rails.logger.info "Associated PaymentTransaction found, skip."
        else
          d = deposit(block, txid, payer, address, amount, receive_at, memo, @channel)
          Rails.logger.info "Deposit##{d.id} created." if d
        end
      end
    end

    def deposit(blockid, txid, payer, address, amount, receive_at, memo, channel)
      tx = @pt_class.create!(
        blockid: blockid,
        txid: txid,
        payer: payer,
        address: address,
        amount: amount,
        confirmations: 0,
        receive_at: receive_at,
        currency: channel.currency
      )

      unless account = PaymentAddress.destruct_memo(memo)
        Rails.logger.info "Transaction##{txid} failed memo checksum validation (memo: #{memo}), PaymentTransaction##{tx.id} failed to deposit."
        return
      end

      if tx.member && tx.account == account
        deposit = channel.kls.create!(
          payment_transaction_id: tx.id,
          blockid: tx.blockid,
          txid: tx.txid,
          amount: tx.amount,
          member: tx.member,
          account: tx.account,
          currency: tx.currency,
          memo: tx.confirmations
        )

        deposit.submit!
        deposit
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
