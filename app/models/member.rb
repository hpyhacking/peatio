class Member < ActiveRecord::Base
  acts_as_taggable

  has_many :orders
  has_many :accounts
  has_many :withdraws
  has_many :fund_sources
  has_many :deposits
  has_and_belongs_to_many :trades

  has_one :two_factor
  has_one :id_document

  delegate :activated?, to: :two_factor, prefix: true
  delegate :verified?, to: :id_document, prefix: true

  has_many :authentications, dependent: :destroy

  validates :sn, presence: true
  before_validation :generate_sn

  before_create :create_accounts
  after_commit :send_activation

  alias_attribute :full_name, :name

  class << self
    def from_auth(auth_hash)
      member = locate_auth(auth_hash) || locate_email(auth_hash) || create_from_auth(auth_hash)
      member
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
      member = create(email: auth_hash['info']['email'])
      member.add_auth(auth_hash)
      member
    end
  end

  def self.admins
    Figaro.env.admin.split(',')
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
    Pusher["private-#{self.sn}"].trigger_async(event, data)
  end

  def to_s
    "#{name || email} - #{sn}"
  end

  def initial?
    name? and !name.empty?
  end

  def get_account(currency)
    self.accounts.with_currency(currency.to_sym).first
  end

  def touch_accounts
    less = Currency.codes.keys - self.accounts.map(&:currency).map(&:to_sym)
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

  alias :ac :get_account

  private
  def generate_sn
    self.sn and return
    begin 
      self.sn = "PEA#{ROTP::Base32.random_base32(8).upcase}TIO"
    end while Member.where(:sn => self.sn).any?
  end

  def create_accounts
    self.accounts = Currency.codes.map do |key, code|
      Account.new(currency: code, balance: 0, locked: 0)
    end
  end
end
