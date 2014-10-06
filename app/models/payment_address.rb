class PaymentAddress < ActiveRecord::Base
  include Currencible
  belongs_to :account

  after_commit :gen_address, on: :create

  has_many :transactions, class_name: 'PaymentTransaction', foreign_key: 'address', primary_key: 'address'

  validates_uniqueness_of :address, allow_nil: true

  def gen_address
    if account && %w(btsx dns).include?(account.currency)
      self.address = "#{currency_obj.deposit_account}|#{self.class.construct_memo(account)}"
      save
    else
      payload = { payment_address_id: id, currency: currency }
      attrs   = { persistent: true }
      AMQPQueue.enqueue(:deposit_coin_address, payload, attrs)
    end
  end

  def self.construct_memo(account)
    member = account.member
    checksum = member.created_at.to_i.to_s[-3..-1]
    "#{member.id}#{checksum}"
  end

  def self.destruct_memo(memo)
    member_id = memo[0...-3]
    checksum  = memo[-3..-1]

    member = Member.find_by_id member_id
    return nil unless member
    return nil unless member.created_at.to_i.to_s[-3..-1] == checksum
    member
  end

end
