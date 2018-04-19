require 'securerandom'

class Member < ActiveRecord::Base
  has_many :orders
  has_many :accounts
  has_many :payment_addresses, through: :accounts
  has_many :withdraws, -> { order(id: :desc) }
  has_many :deposits, -> { order(id: :desc) }

  has_many :authentications, dependent: :destroy

  scope :enabled, -> { where(disabled: false) }

  before_validation :sanitize, :assign_sn

  validates :sn, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, email: true

  after_create  :touch_accounts
  after_update  :sync_update

  attr_readonly :email

  class << self
    def from_auth(auth_hash)
      (locate_auth(auth_hash) || locate_email(auth_hash) || Member.new).tap do |member|
        member.transaction do
          info_hash       = auth_hash.fetch('info')
          member.email    = info_hash.fetch('email')
          member.level    = Member::Levels.get(info_hash['level']) if info_hash.key?('level')
          member.disabled = info_hash.key?('state') && info_hash['state'] != 'active'
          member.save!
          auth = Authentication.locate(auth_hash) || member.authentications.build_auth(auth_hash)
          auth.token = auth_hash.dig('credentials', 'token')
          auth.save!
        end
      end
    end

    def current
      Thread.current[:user]
    end

    def current=(user)
      Thread.current[:user] = user
    end

    def admins
      Figaro.env.admin.split(',')
    end

    def search(field: nil, term: nil)
      case field
        when 'email', 'sn'
          where("members.#{field} LIKE ?", "%#{term}%")
        when 'wallet_address'
          joins(:payment_addresses).where('payment_addresses.address LIKE ?', "%#{term}%")
        else
          all
      end.order(:id).reverse_order
    end

    private

    def locate_auth(auth_hash)
      Authentication.locate(auth_hash).try(:member)
    end

    def locate_email(auth_hash)
      find_by_email(auth_hash.dig('info', 'email'))
    end
  end

  def trades
    Trade.where('bid_member_id = ? OR ask_member_id = ?', id, id)
  end

  def admin?
    @is_admin ||= self.class.admins.include?(self.email)
  end

  def trigger(event, data)
    AMQPQueue.enqueue(:pusher_member, {member_id: id, event: event, data: data})
  end

  def notify(event, data)
    ::Pusher["private-#{sn}"].trigger_async event, data
  end

  def to_s
    "#{email} - #{sn}"
  end

  def get_account(model_or_code)
    accounts.with_currency(model_or_code).first.yield_self do |account|
      touch_accounts unless account
      accounts.with_currency(model_or_code).first
    end
  end
  alias :ac :get_account

  def touch_accounts
    Currency.find_each do |currency|
      next if accounts.where(currency: currency).exists?
      accounts.create!(currency: currency, balance: 0, locked: 0)
    end
  end

  def auth(name)
    authentications.where(provider: name).first
  end

  def auth_with?(name)
    auth(name).present?
  end

  def remove_auth(name)
    auth(name).destroy
  end

  def as_json(options = {})
    super(options).merge({
      "memo" => self.id
    })
  end

  def level
    self[:level].to_s.inquiry
  end

  def uid
    authentications.barong.first&.uid || email
  end

  private

  def sanitize
    self.email.try(:downcase!)
  end

  def assign_sn
    return unless sn.blank?
    begin
      self.sn = random_sn
    end while Member.where(sn: self.sn).any?
  end
  
  def random_sn
    "SN#{SecureRandom.hex(5).upcase}"
  end
  
  def sync_update
    ::Pusher["private-#{sn}"].trigger_async('members', { type: 'update', id: self.id, attributes: changed_attributes })
  end
end

# == Schema Information
# Schema version: 20180216145412
#
# Table name: members
#
#  id           :integer          not null, primary key
#  level        :string(20)       default("")
#  sn           :string(12)       not null
#  email        :string(255)      not null
#  disabled     :boolean          default(FALSE), not null
#  api_disabled :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_members_on_sn  (sn) UNIQUE
#
