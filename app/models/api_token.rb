class APIToken < ActiveRecord::Base
  paranoid

  belongs_to :member

  serialize :trusted_ip_list

  validates_presence_of :access_key, :secret_key

  before_validation :generate_keys, on: :create

  def self.from_token(token)
    return nil unless token && token.token.present?
    access_key, secret_key = token.token.split(':')
    find_by_access_key access_key
  end

  def to_token
    [access_key, secret_key].join(':')
  end

  def expired?
    expires_at && expires_at < Time.now
  end

  def in_scopes?(ary)
    return true if ary.blank?
    return true if self[:scopes] == 'all'
    (ary & scopes).present?
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

  def scopes
    self[:scopes] ? self[:scopes].split(/\s+/) : []
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

# == Schema Information
# Schema version: 20180215144645
#
# Table name: api_tokens
#
#  id              :integer          not null, primary key
#  member_id       :integer          not null
#  access_key      :string(50)       not null
#  secret_key      :string(50)       not null
#  created_at      :datetime
#  updated_at      :datetime
#  trusted_ip_list :string(255)
#  label           :string(255)
#  expires_at      :datetime
#  scopes          :string(255)
#  deleted_at      :datetime
#
# Indexes
#
#  index_api_tokens_on_access_key  (access_key) UNIQUE
#  index_api_tokens_on_secret_key  (secret_key) UNIQUE
#
