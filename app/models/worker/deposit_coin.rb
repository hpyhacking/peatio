# TODO: Replace txout with composite TXID.
module Worker
  class DepositCoin

    def process(payload)
      payload.symbolize_keys!

      ccy = Currency.find_by_code!(payload.fetch(:currency))
      tx  = ccy.api.load_deposit(payload.fetch(:txid))

      if tx
        Rails.logger.info "Processing #{ccy.code.upcase} deposit: #{payload.fetch(:txid)}."
        ActiveRecord::Base.transaction do
          tx.fetch(:entries).each_with_index { |entry, index| deposit!(ccy, tx, entry, index) }
        end
      else
        Rails.logger.info "Could not load #{ccy.code.upcase} deposit #{payload.fetch(:txid)}."
      end
    end

  private

    def deposit!(currency, tx, entry, index)
      return Rails.logger.info "Skipped #{tx.fetch(:id)}:#{index}." unless deposit_entry_processable?(currency, tx, entry, index)

      pt = PaymentTransaction::Normal.create! \
        txid:          tx[:id],
        txout:         index,
        address:       entry[:address],
        amount:        entry[:amount],
        confirmations: tx[:confirmations],
        receive_at:    tx[:received_at],
        currency:      currency

      deposit = "deposits/#{currency.type}".camelize.constantize.create! \
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

    def deposit_entry_processable?(currency, tx, entry, index)
      PaymentAddress.where(currency: currency, address: entry[:address]).exists? &&
        !PaymentTransaction::Normal.where(txid: tx[:id], txout: index).exists?
    end
  end
end
