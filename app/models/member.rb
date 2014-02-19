class Member < ActiveRecord::Base
  acts_as_taggable

  has_many :orders
  has_many :accounts
  has_many :withdraw_addresses, through: :accounts
  has_many :deposits
  has_many :withdraws
  has_many :deposits, through: :accounts
  belongs_to :identity
  has_and_belongs_to_many :trades

  validates :sn, presence: true

  before_validation :generate_sn
  before_create :create_accounts

  def initial?
    name? and !name.empty?
  end

  def admin?
    @is_admin ||= self.class.admins.include?(self.email)
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

  class << self
    def from_auth(auth)
      find_auth(auth) || create_auth(auth)
    end

    def find_auth(auth)
      Member.find_by_email(auth[:info][:email])
    end

    def create_auth(auth)
      m = Member.new
      m.identity_id = auth.uid
      m.email = auth[:info][:email]
      m.save! && m
    end

    def admins
      Figaro.env.admin.split(',')
    end
  end

  def trigger(event, data)
    Pusher["private-#{self.sn}"].trigger_async(event, data)
  end

  def to_s
    "#{name} - #{sn}"
  end

  def generate_sn
    self.sn and return
    begin 
      self.sn = "PEA#{ROTP::Base32.random_base32(8).upcase}TIO"
    end while Member.where(:sn => self.sn).any?
  end

  private

  def create_accounts
    self.accounts = Currency.codes.map do |key, code|
      Account.new(currency: code, balance: 0, locked: 0)
    end
  end
end
