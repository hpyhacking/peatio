class Member < ActiveRecord::Base
  acts_as_taggable
  acts_as_reader

  has_many :orders
  has_many :accounts
  has_many :payment_addresses, through: :accounts
  has_many :withdraws
  has_many :fund_sources
  has_many :deposits
  has_many :api_tokens
  has_many :two_factors
  has_many :tickets, foreign_key: 'author_id'
  has_many :comments, foreign_key: 'author_id'
  has_many :signup_histories

  has_one :id_document

  has_many :authentications, dependent: :destroy

  scope :enabled, -> { where(disabled: false) }

  delegate :activated?, to: :two_factors, prefix: true, allow_nil: true
  delegate :name,       to: :id_document, allow_nil: true
  delegate :full_name,  to: :id_document, allow_nil: true
  delegate :verified?,  to: :id_document, prefix: true, allow_nil: true

  before_validation :sanitize, :generate_sn

  validates :sn, presence: true
  validates :display_name, uniqueness: true, allow_blank: true
  validates :email, email: true, uniqueness: true, allow_nil: true

  before_create :build_default_id_document
  after_create  :touch_accounts
  after_update :resend_activation
  after_update :sync_update

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
               when 'phone_number'
                 where('members.phone_number LIKE ?', "%#{term}%")
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
      return nil if auth_hash['info']['email'].blank?
      member = find_by_email(auth_hash['info']['email'])
      return nil unless member
      member.add_auth(auth_hash)
      member
    end

    def create_from_auth(auth_hash)
      member = create(email: auth_hash['info']['email'], nickname: auth_hash['info']['nickname'],
                      activated: false)
      member.add_auth(auth_hash)
      member.send_activation if auth_hash['provider'] == 'identity'
      member
    end
  end


  def create_auth_for_identity(identity)
    self.authentications.create(provider: 'identity', uid: identity.id)
  end

  def trades
    Trade.where('bid_member_id = ? OR ask_member_id = ?', id, id)
  end

  def active!
    update activated: true
  end

  def update_password(password)
    identity.update password: password, password_confirmation: password
    send_password_changed_notification
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
    authentication = authentications.find_by(provider: 'identity')
    authentication ? Identity.find(authentication.uid) : nil
  end

  def auth(name)
    authentications.where(provider: name).first
  end

  def auth_with?(name)
    auth(name).present?
  end

  def remove_auth(name)
    identity.destroy if name == 'identity'
    auth(name).destroy
  end

  def send_activation
    Token::Activation.create(member: self)
  end

  def send_password_changed_notification
    MemberMailer.reset_password_done(self.id).deliver

    if sms_two_factor.activated?
      sms_message = I18n.t('sms.password_changed', email: self.email)
      AMQPQueue.enqueue(:sms_notification, phone: phone_number, message: sms_message)
    end
  end

  def unread_comments
    ticket_ids = self.tickets.open.collect(&:id)
    if ticket_ids.any?
      Comment.where(ticket_id: [ticket_ids]).where("author_id <> ?", self.id).unread_by(self).to_a
    else
      []
    end
  end

  def app_two_factor
    two_factors.by_type(:app)
  end

  def sms_two_factor
    two_factors.by_type(:sms)
  end

  def as_json(options = {})
    super(options).merge({
      "name" => self.name,
      "app_activated" => self.app_two_factor.activated?,
      "sms_activated" => self.sms_two_factor.activated?,
      "memo" => self.id
    })
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

  def resend_activation
    self.send_activation if self.email_changed?
  end

  def sync_update
    ::Pusher["private-#{sn}"].trigger_async('members', { type: 'update', id: self.id, attributes: self.changes_attributes_as_json })
  end
end
