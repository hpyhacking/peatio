class PaymentAddress < ActiveRecord::Base
  include Currencible
  belongs_to :account

  has_many :transactions, class_name: 'PaymentTransaction', foreign_key: 'address', primary_key: 'address'

  validates_uniqueness_of :address
end
