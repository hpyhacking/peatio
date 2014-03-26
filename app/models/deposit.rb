class Deposit < ActiveRecord::Base
  extend Enumerize
  enumerize :currency, in: Currency.codes
  enumerize :state, in: {:wait => 100, :done => 500}

  belongs_to :member
  belongs_to :account
  validates_presence_of :address_type, :address, :address_label, :amount, :account_id, :member_id, :currency, :state
  validates_presence_of :tx_id
  validates_uniqueness_of :tx_id

  attr_accessor :sn
end
