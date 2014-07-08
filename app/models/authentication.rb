# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  provider   :string(255)
#  uid        :string(255)
#  token      :string(255)
#  secret     :string(255)
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Authentication < ActiveRecord::Base
  belongs_to :member

  validates :provider, presence: true, uniqueness: { scope: :member_id }
  validates :uid,      presence: true, uniqueness: { scope: :provider }

  class << self
    def locate(auth)
      uid      = auth['uid'].to_s
      provider = auth['provider']
      find_by_provider_and_uid provider, uid
    end

    def build_auth(auth)
      new \
        uid:      auth['uid'],
        provider: auth['provider'],
        token:    auth['credentials'].try(:[], 'token'),
        secret:   auth['credentials'].try(:[], 'secret')
    end
  end
end
