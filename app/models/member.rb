class Member < ActiveRecord::Base
  has_many :orders
  has_many :accounts
  has_many :payment_addresses, through: :accounts
  has_many :withdraws
  has_many :fund_sources
  has_many :deposits
  has_many :api_tokens

  has_one :id_document

  has_many :authentications, dependent: :destroy

  scope :enabled, -> { where(disabled: false) }

  delegate :name,       to: :id_document, allow_nil: true
  delegate :full_name,  to: :id_document, allow_nil: true
  delegate :verified?,  to: :id_document, prefix: true, allow_nil: true

  before_validation :sanitize, :generate_sn

  validates :sn, presence: true
  validates :email, presence: true, uniqueness: true, email: true

  before_create :build_default_id_document
  after_create  :touch_accounts
  after_update  :sync_update

  class << self
    def from_auth(auth_hash)
      locate_auth(auth_hash) || locate_email(auth_hash) || create_from_auth(auth_hash)
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
      result = case field
               when 'email'
                 where('members.email LIKE ?', "%#{term}%")
               when 'name'
                 joins(:id_document).where('id_documents.name LIKE ?', "%#{term}%")
               when 'wallet_address'
                 members = joins(:fund_sources).where('fund_sources.uid' => term)
                 if members.empty?
                  members = joins(:payment_addresses).where('payment_addresses.address' => term)
                 end
                 members
               else
                 all
               end

      result.order(:id).reverse_order
    end

    private

    def locate_auth(auth_hash)
      Authentication.locate(auth_hash).try(:member)
    end

    def locate_email(auth_hash)
      email = auth_hash.dig('info', 'email')
      return if email.blank?

      find_by_email(email).tap do |member|
        member&.add_auth(auth_hash)
      end
    end

    def create_from_auth(auth_hash)
      new(email:    auth_hash['info']['email'],
          nickname: auth_hash['info']['nickname']
      ).tap do |member|
        member.save!
        member.add_auth(auth_hash)
      end
    end
  end

  def trades
    Trade.where('bid_member_id = ? OR ask_member_id = ?', id, id)
  end

  def admin?
    @is_admin ||= self.class.admins.include?(self.email)
  end

  def add_auth(auth_hash)
    authentications.build_auth(auth_hash).save!
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
    less = Currency.codes.map(&:to_s) - self.accounts.map(&:currency).map(&:to_s)
    less.each do |code|
      self.accounts.create!(currency: code, balance: 0, locked: 0)
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
      "name" => self.name,
      "memo" => self.id
    })
  end

  def jwt
    JWT.encode({ email: email }, APIv2::Auth::Utils.jwt_shared_secret_key, 'RS256')
  end

  private

  def sanitize
    self.email.try(:downcase!)
  end

  def generate_sn
    self.sn and return
    begin
      self.sn = "PEA#{ROTP::Base32.random_base32(8).upcase}TIO"
    end while Member.where(:sn => self.sn).any?
  end

  def build_default_id_document
    build_id_document
    true
  end

  def sync_update
    ::Pusher["private-#{sn}"].trigger_async('members', { type: 'update', id: self.id, attributes: self.changes_attributes_as_json })
  end
end
