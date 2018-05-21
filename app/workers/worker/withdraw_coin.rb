# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class WithdrawCoin
    def process(payload)
      payload.symbolize_keys!

      withdraw = Withdraw.lock.find_by_id(payload[:id])
      return if withdraw.blank? || !withdraw.processing?

      withdraw.transaction do
        balance = CoinAPI[withdraw.currency.code.to_sym].load_balance!
        return withdraw.suspect! if balance < withdraw.sum

        pa = withdraw.account.payment_address

        txid = CoinAPI[withdraw.currency.code.to_sym].create_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: withdraw.rid },
          withdraw.amount.to_d
        )

        withdraw.whodunnit 'Worker::WithdrawCoin' do
          withdraw.txid = txid
          withdraw.success
          withdraw.save!
        end
      end

    rescue Exception => e
      Rails.logger.error { 'Error during withdraw processing.' }
      Rails.logger.debug { "Failed to process #{withdraw.currency.code} withdraw with ID #{withdraw.id}: #{e.inspect}." }
    ensure
      withdraw.fail!
    end
  end
end
