class FundSource < ActiveRecord::Base
  extend Enumerize
  enumerize :currency, in: Currency.codes, scope: true

  attr_accessor :name

  paranoid

  belongs_to :member

  validates_presence_of :uid, :extra, :member
  validate :validate_coin_address, :if => 'coin?'

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
    result = CoinRPC[currency].validateaddress(self.address)
    if result[:isvalid] == false
      errors.add(:address, :invalid)
    elsif result[:ismine] == true or \
      PaymentAddress.find_by_address(self.address)
      errors.add(:address, :ismine)
    end
  end
end
