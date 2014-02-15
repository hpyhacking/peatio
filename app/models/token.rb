class Token < ActiveRecord::Base
  attr_accessor :email
  attr_accessor :skip
  belongs_to :identity

  before_validation :generate_token, :if => 'token.nil?'
  before_validation :check_email, :on => :create, :if => 'email'
  before_create :invalidate_old_tokens
  after_commit :send_token, on: :create
  after_update :used

  validates :email, presence: true, email: true, on: :create
  validates_presence_of :identity, :token
  validate :check_latest_send, on: :create

  scope :with_identity, -> (identity_id) { where("identity_id = ?", identity_id) }
  scope :with_token, -> (token) { where("token = ?", token) }
  scope :available, -> { where("expire_at > ?", DateTime.now).where("is_used = ?", false) }

  def to_param
    self.token
  end

  def self.verify(token)
    with_token(token).available.any?
  end

  private
  def used
    self.is_used = true
  end

  def send_token
    email = identity.email
    mailer = self.class.model_name.param_key
    TokenMailer.send(mailer, email, token).deliver
  end

  def invalidate_old_tokens
    self.class.available.with_identity(identity_id).update_all(is_used: true)
  end

  def check_latest_send
    latest = self.class.
      available.
      with_identity(self.identity_id).
      order('created_at desc').first

    if latest && latest.created_at > DateTime.now.ago(60 * 5)
      self.errors.add(:base, :too_soon)
    end
  end

  def generate_token
    self.is_used = false
    self.token = SecureRandom.hex(16)
    self.expire_at = DateTime.now.since(60 * 30)
  end

  def check_email
    identity = Identity.find_by_email(self.email)
    if identity
      self.identity_id = identity.id
    else
      self.errors.add(:email, :match)
    end
  end
end
