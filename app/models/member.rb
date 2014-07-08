# == Schema Information
#
# Table name: members
#
#  id                    :integer          not null, primary key
#  sn                    :string(255)
#  name                  :string(255)
#  display_name          :string(255)
#  email                 :string(255)
#  identity_id           :integer
#  created_at            :datetime
#  updated_at            :datetime
#  state                 :integer
#  activated             :boolean
#  country_code          :integer
#  phone_number          :string(255)
#  phone_number_verified :boolean
#

class Member < ActiveRecord::Base
  acts_as_taggable

  has_many :orders
  has_many :accounts
  has_many :withdraws
  has_many :fund_sources
  has_many :deposits
  has_many :api_tokens
  has_many :two_factors

  has_one :id_document
  has_one :sms_token

  delegate :activated?, to: :two_factors, prefix: true, allow_nil: true
  delegate :verified?,  to: :id_document, prefix: true, allow_nil: true
  delegate :verified?,  to: :sms_token,   prefix: true

  has_many :authentications, dependent: :destroy

  validates :sn, presence: true
  validates :display_name, uniqueness: true, allow_blank: true
  before_validation :generate_sn

  alias_attribute :full_name, :name

  after_create :touch_accounts

  class << self
    def from_auth(auth_hash)
      member = locate_auth(auth_hash) || locate_email(auth_hash) || create_from_auth(auth_hash)
      member
    end

    def current
      Thread.current[:user]
    end

    def current=(user)
      Thread.current[:user] = user
    end

    private

    def locate_auth(auth_hash)
      Authentication.locate(auth_hash).try(:member)
    end

    def locate_email(auth_hash)
      member = find_by_email(auth_hash['info']['email'])
      return nil unless member
      member.add_auth(auth_hash)
      member
    end

    def create_from_auth(auth_hash)
      member = create(email: auth_hash['info']['email'], activated: false)
      member.add_auth(auth_hash)
      member.send_activation
      member
    end
  end

  def self.admins
    Figaro.env.admin.split(',')
  end

  def trades
    Trade.where('bid_member_id = ? OR ask_member_id = ?', id, id)
  end

  def active
    self.update_column(:activated, true)
  end

  def admin?
    @is_admin ||= self.class.admins.include?(self.email)
  end

  def add_auth(auth_hash)
    authentications.build_auth(auth_hash).save
  end

  def trigger(event, data)
    AMQPQueue.enqueue(:pusher_member, {member_id: id, event: event, data: data})
  end

  def notify(event, data)
    ::Pusher["private-#{sn}"].trigger_async event, data
  end

  def to_s
    "#{name || email} - #{sn}"
  end

  def to_muut
    {
      id: id,
      displayname: display_name,
      email: email,
      avatar: gravatar,
      is_admin: admin?
    }
  end

  def gravatar
    "//gravatar.com/avatar/" + Digest::MD5.hexdigest(email.strip.downcase) + "?d=retro"
  end

  def initial?
    name? and !name.empty?
  end

  def get_account(currency)
    account = accounts.with_currency(currency.to_sym).first

    if account.nil?
      touch_accounts
      account = accounts.with_currency(currency.to_sym).first
    end

    account
  end
  alias :ac :get_account

  def touch_accounts
    less = Currency.codes - self.accounts.map(&:currency).map(&:to_sym)
    less.each do |code|
      self.accounts.create(currency: code, balance: 0, locked: 0)
    end
  end

  def identity
    Identity.find(authentications.find_by_provider('identity').uid)
  end

  def send_activation
    Activation.create(member: self)
  end

  private
  def generate_sn
    self.sn and return
    begin
      self.sn = "PEA#{ROTP::Base32.random_base32(8).upcase}TIO"
    end while Member.where(:sn => self.sn).any?
  end
end
