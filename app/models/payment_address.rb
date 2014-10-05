class PaymentAddress < ActiveRecord::Base
  include Currencible
  belongs_to :account

  after_commit :gen_address, on: :create

  has_many :transactions, class_name: 'PaymentTransaction', foreign_key: 'address', primary_key: 'address'

  validates_uniqueness_of :address, allow_nil: true

  def gen_address
    if account && %w(btsx dns).include?(account.currency)
      self.address = "#{currency_obj.deposit_account}|#{construct_memo(account)}"
      save
    else
      payload = { payment_address_id: id, currency: currency }
      attrs   = { persistent: true }
      AMQPQueue.enqueue(:deposit_coin_address, payload, attrs)
    end
  end

  def construct_memo(account)
    member_id = account.member_id.to_s
    size      = member_id.size.to_s(16).upcase
    "#{member_id}#{account.id}#{size}"
  end

  def destruct_memo(memo)
    size = memo.last.to_i(16)
    return nil if size > (memo.size-2)

    member_id = memo[0..(size-1)]
    member = Member.find_by_id member_id
    return nil unless member

    account_id = memo[size..-2]
    member.accounts.where(id: account_id).first
  end

end
