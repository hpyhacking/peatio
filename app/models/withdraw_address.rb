class WithdrawAddress < ActiveRecord::Base
  extend Enumerize

  paranoid
  enumerize :category, in: WithdrawChannel.enumerize

  belongs_to :account

  validates_presence_of :label, :address, :category, :account_id
  validate :validate_alipay_address, :if => 'category.try(:alipay?)'
  validate :validate_coin_address, :if => 'coin?'

  def coin?
    category.try(:satoshi?) or category.try(:protoshares?)
  end

  def to_s
    "#{label} @ #{address}"
  end

  private

  def validate_alipay_address
    unless /\A(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))|(1\d{10})\z/i =~ self.address
      errors.add(:address, :alipay_invalid)
    end
  end

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
