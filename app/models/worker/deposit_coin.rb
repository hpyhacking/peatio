# TODO: Replace txout with composite TXID.
module Worker
  class DepositCoin

    def process(payload)
      payload.symbolize_keys!
      channel = DepositChannel.find_by_key(payload.fetch(:channel_key))
      Rails.logger.info "Processing #{channel.currency_obj.code.upcase} deposit: #{payload.fetch(:txid)}."
      tx = channel.currency_obj.api.load_deposit(payload.fetch(:txid))
      tx.fetch(:entries).each_with_index do |entry, index|
        deposit!(channel, tx, entry, index)
      end if tx
    end

  private

    def deposit!(channel, tx, entry, index)
      unless processable?(channel, tx, entry, index)
        return Rails.logger.info "Skipped #{tx.fetch(:id)}."
      end

      ActiveRecord::Base.transaction do
        tx = PaymentTransaction::Normal.create! \
          txid: tx[:id],
          txout: index,
          address: entry[:address],
          amount: entry[:amount],
          confirmations: tx[:confirmations],
          receive_at: tx[:received_at],
          currency: channel.currency

        deposit = channel.kls.create! \
          payment_transaction_id: tx.id,
          txid: tx.txid,
          txout: tx.txout,
          amount: tx.amount,
          member: tx.member,
          account: tx.account,
          currency: tx.currency,
          confirmations: tx.confirmations

        deposit.submit!
      end
      Rails.logger.info "Successfully processed #{tx.txid}."
    rescue => e
      Rails.logger.error 'Failed to process deposit.'
      Rails.logger.debug { tx.inspect }
      report_exception(e)
    end

    def processable?(channel, tx, entry, index)
      PaymentAddress.where(currency: channel.currency_obj.id, address: entry[:address]).exists? &&
        !PaymentTransaction::Normal.where(txid: tx[:id], txout: index).exists?
    end
  end
end
