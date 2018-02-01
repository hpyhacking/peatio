# TODO: Replace txout with composite TXID.
module Worker
  class DepositCoin

    def process(payload)
      payload.symbolize_keys!

      channel = DepositChannel.find_by_key(payload.fetch(:channel_key))
      tx      = channel.currency_obj.api.load_deposit(payload.fetch(:txid))

      Rails.logger.info "Processing #{channel.currency_obj.code.upcase} deposit: #{payload.fetch(:txid)}."
      Rails.logger.info "Could not load #{channel.currency_obj.code.upcase} deposit #{payload.fetch(:txid)}." unless tx

      ActiveRecord::Base.transaction do
        tx.fetch(:entries).each_with_index { |entry, index| deposit!(channel, tx, entry, index) }
      end
    end

  private

    def deposit!(channel, tx, entry, index)
      return Rails.logger.info "Skipped #{tx.fetch(:id)}:#{index}." unless deposit_entry_processable?(channel, tx, entry, index)

      pt = PaymentTransaction::Normal.create! \
        txid:          tx[:id],
        txout:         index,
        address:       entry[:address],
        amount:        entry[:amount],
        confirmations: tx[:confirmations],
        receive_at:    tx[:received_at],
        currency:      channel.currency

      deposit = channel.kls.create! \
        payment_transaction_id: pt.id,
        txid:                   pt.txid,
        txout:                  pt.txout,
        amount:                 pt.amount,
        member:                 pt.member,
        account:                pt.account,
        currency:               pt.currency,
        confirmations:          pt.confirmations

      deposit.submit!

      Rails.logger.info "Successfully processed #{tx.fetch(:id)}:#{index}."
    rescue => e
      Rails.logger.error { "Failed to process #{tx.fetch(:id)}:#{index}." }
      Rails.logger.debug { tx.inspect }
      report_exception(e)
    end

    def deposit_entry_processable?(channel, tx, entry, index)
      PaymentAddress.where(currency: channel.currency_obj.id, address: entry[:address]).exists? &&
        !PaymentTransaction::Normal.where(txid: tx[:id], txout: index).exists?
    end
  end
end
