class PaymentAddress < ActiveRecord::Base
  include Currencible
  belongs_to :account

  after_commit :gen_address, on: :create

  has_many :transactions, class_name: 'PaymentTransaction', foreign_key: 'address', primary_key: 'address'

  validates_uniqueness_of :address, allow_nil: true

  def gen_address
    payload = { payment_address_id: id, currency: currency }
    attrs   = { persistent: true }
    AMQPQueue.enqueue(:deposit_coin_address, payload, attrs)
  end
end
