# == Schema Information
#
# Table name: api_tokens
#
#  id         :integer          not null, primary key
#  member_id  :integer          not null
#  access_key :string(50)       not null
#  secret_key :string(50)       not null
#  created_at :datetime
#  updated_at :datetime
#

class APIToken < ActiveRecord::Base

  belongs_to :member

  validates_presence_of :access_key, :secret_key

  before_validation :generate_keys, on: :create

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
