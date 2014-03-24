class WithdrawAddress < ActiveRecord::Base
  extend Enumerize

  attr_accessor :name

  paranoid
  enumerize :category, in: WithdrawChannel.enumerize(:currency), scope: true

  belongs_to :account

  validates_presence_of :label, :address, :category, :account_id
  validate :validate_coin_address, :if => 'coin?'

  def coin?
    category.try(:satoshi?) or category.try(:protoshares?)
  end

  def fiat?
    !coin?
  end

  def to_s
    "#{label} @ #{address}"
  end

  private

  def validate_coin_address
    currency = WithdrawChannel.currency(self.category)
    result = CoinRPC[currency].validateaddress(self.address)
    if result[:isvalid] == false
      errors.add(:address, :satoshi_invalid)
    elsif result[:ismine] == true or \
      PaymentAddress.find_by_address(self.address)
      errors.add(:address, :satoshi_ismine)
    end
  end
end
