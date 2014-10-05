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

  has_one :id_document
  has_one :sms_token, class_name: 'Token::SmsToken'

  has_many :authentications, dependent: :destroy

  scope :enabled, -> { where(disabled: false) }
  scope :api_enabled, -> { where(api_disabled: false) }

  delegate :activated?, to: :two_factors, prefix: true, allow_nil: true
  delegate :name,       to: :id_document, allow_nil: true
  delegate :full_name,  to: :id_document, allow_nil: true
  delegate :verified?,  to: :id_document, prefix: true, allow_nil: true
  delegate :verified?,  to: :sms_token,   prefix: true

  before_validation :generate_sn

  validates :sn, presence: true
  validates :display_name, uniqueness: true, allow_blank: true

  before_create :build_default_id_document
  after_create  :touch_accounts

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
    authentication = authentications.find_by(provider: 'identity')
    authentication ? Identity.find(authentication.uid) : nil
  end

  def send_activation
    Token::Activation.create(member: self)
  end

  def send_password_changed_notification
    MemberMailer.reset_password_done(self.id).deliver

    if phone_number_verified?
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

  private
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
end
