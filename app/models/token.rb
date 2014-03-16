class Token < ActiveRecord::Base
  belongs_to :tokenable, polymorphic: true

  define_callbacks :confirmed

  before_validation :generate_token, :if => 'token.nil?'
  before_create :invalidate_earlier_tokens
  after_commit :send_token
  before_update :confirmed

  validates_presence_of :tokenable, :token
  validate :check_latest_send, on: :create

  def to_param
    self.token
  end

  scope :of, -> (tokenable) { where(tokenable: tokenable) }
  scope :with_token, -> (token) { where("token = ?", token) }
  scope :available, -> { where("expire_at > ?", DateTime.now).where("is_used = ?", false) }

  def self.head
    order('created_at desc').first
  end

  def self.verify(token)
    with_token(token).available.any?
  end

  def email
    tokenable.try(:email) || tokenable.try(:member).try(:email)
  end

  private

  def confirmed
    run_callbacks :confirmed do
      self.is_used = true
    end
  end

  def send_token
    mailer = self.class.model_name.param_key
    TokenMailer.send(mailer, email, token).deliver
  end

  def invalidate_earlier_tokens
    self.class.available.of(tokenable).update_all(is_used: true)
  end

  def check_latest_send
    latest = self.class.available.of(tokenable).head

    if latest && latest.created_at > DateTime.now.ago(60 * 5)
      self.errors.add(:base, :too_soon)
    end
  end

  def generate_token
    self.is_used = false
    self.token = SecureRandom.hex(16)
    self.expire_at = DateTime.now.since(60 * 30)
  end
end
