module DepositCoinable
  extend ActiveSupport::Concern

  included do
    validates_uniqueness_of :txid
    belongs_to :payment_transaction, foreign_key: 'txid', primary_key: 'txid'
  end

  def channel
    @channel ||= DepositChannel.find_by_key(self.class.name.demodulize.underscore)
  end

  def min_confirm?(confirmations)
    update_confirmations(confirmations)
    confirmations >= channel.min_confirm && confirmations < channel.max_confirm
  end

  def max_confirm?(confirmations)
    update_confirmations(confirmations)
    confirmations >= channel.max_confirm
  end

  def update_confirmations(confirmations)
    if !self.new_record? && self.memo.to_s != confirmations.to_s
      self.update_attribute(:memo, confirmations.to_s)
    end
  end

  def blockchain_url
    currency_obj.blockchain_url(txid)
  end
end
