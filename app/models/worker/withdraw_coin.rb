module Worker
  class WithdrawCoin
    def process(payload)
      payload.symbolize_keys!

      withdraw = Withdraw.lock.find_by_id(payload[:id])
      return if withdraw.blank? || !withdraw.processing?

      withdraw.transaction do
        balance = CoinAPI[withdraw.currency.to_sym].load_balance!
        withdraw.mark_suspect if balance < withdraw.sum

        fee = [withdraw.fee.to_f || withdraw.channel.try(:fee) || 0.0005, 0.1].min

        pa = withdraw.account.payment_address

        txid = CoinAPI[withdraw.currency.to_sym].create_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: withdraw.fund_uid },
          withdraw.amount.to_d,
          fee.to_d
        )

        withdraw.whodunnit 'Worker::WithdrawCoin' do
          withdraw.update_columns(txid: txid, done_at: Time.current)

          # withdraw.succeed! will start another transaction, cause
          # Account after_commit callbacks not to fire
          withdraw.succeed
          withdraw.save!
        end
      end

    rescue Exception => e
      Rails.logger.error { 'Error during withdraw processing.' }
      Rails.logger.debug { "Failed to process #{withdraw.currency.upcase} withdraw with ID #{withdraw.id}: #{e.inspect}." }
      withdraw.fail!
    end
  end
end
