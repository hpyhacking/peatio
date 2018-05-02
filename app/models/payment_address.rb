class PaymentAddress < ActiveRecord::Base
  include Currencible
  belongs_to :account

  after_commit :enqueue_address_generation

  has_many :transactions, class_name: 'Deposits::Coin', foreign_key: :address, primary_key: :address

  validates_uniqueness_of :address, allow_nil: true

  serialize :details, JSON

  before_validation do
    next unless currency&.code&.bch? && address?
    self.address = CashAddr::Converter.to_legacy_address(address)
  end

  before_validation do
    next unless currency&.case_insensitive?
    self.address = address.try(:downcase)
  end

  def enqueue_address_generation
    if address.blank? && currency.coin?
      AMQPQueue.enqueue(:deposit_coin_address, { account_id: account.id }, { persistent: true })
    end
  end

  def memo
    address && address.split('|', 2).last
  end

  def deposit_address
    currency[:deposit_account] || address
  end

  def as_json(options = {})
    {
      account_id: account_id,
      deposit_address: deposit_address
    }.merge(options)
  end

  def trigger_deposit_address
    ::Pusher["private-#{account.member.sn}"].trigger_async('deposit_address', {type: 'create', attributes: as_json})
  end

  def self.construct_memo(obj)
    member = obj.is_a?(Account) ? obj.member : obj
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

  def to_json
    {address: deposit_address}
  end
end

# == Schema Information
# Schema version: 20180501141718
#
# Table name: payment_addresses
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  address     :string(64)
#  created_at  :datetime
#  updated_at  :datetime
#  currency_id :integer
#  secret      :string(255)
#  details     :string(1024)     default({}), not null
#
# Indexes
#
#  index_payment_addresses_on_currency_id  (currency_id)
#
