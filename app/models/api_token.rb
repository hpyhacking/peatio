class APIToken < ActiveRecord::Base

  belongs_to :member
  belongs_to :oauth_access_token, class_name: 'Doorkeeper::AccessToken'

  serialize :trusted_ip_list

  validates_presence_of :access_key, :secret_key

  before_validation :generate_keys, on: :create

  def expired?
    expire_at && expire_at < Time.now
  end

  def allow_ip?(ip)
    trusted_ip_list.blank? || trusted_ip_list.include?(ip)
  end

  def ip_whitelist=(list)
    self.trusted_ip_list = list.split(/,\s*/)
  end

  def ip_whitelist
    trusted_ip_list.try(:join, ',')
  end

  def to_oauth_token
    [access_key, secret_key].join(':')
  end

  private

  def generate_keys
    begin
      self.access_key = APIv2::Auth::Utils.generate_access_key
    end while APIToken.where(access_key: access_key).any?

    begin
      self.secret_key = APIv2::Auth::Utils.generate_secret_key
    end while APIToken.where(secret_key: secret_key).any?
  end

end
