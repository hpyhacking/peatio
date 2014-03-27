class FundSource < ActiveRecord::Base
  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true

  attr_accessor :name

  paranoid

  belongs_to :member

  validates_presence_of :uid, :extra, :member
  validate :validate_coin_address, :if => 'coin?'

  scope :with_channel, -> (channel_id) { where channel_id: channel_id }

  def coin?
    self.currency == 'btc'
  end

  def fiat?
    !coin?
  end

  def to_s
    "#{uid} @ #{extra}"
  end

  private

  def validate_coin_address
    result = CoinRPC[currency].validateaddress(self.uid)
    if result[:isvalid] == false
      errors.add(:uid, :invalid)
    elsif result[:ismine] == true or \
      PaymentAddress.find_by_address(self.uid)
      errors.add(:uid, :ismine)
    end
  end
end
