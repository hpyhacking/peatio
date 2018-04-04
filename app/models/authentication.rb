class Authentication < ActiveRecord::Base
  belongs_to :member, required: true

  validates :provider, presence: true, uniqueness: { scope: :member_id }
  validates :uid,      presence: true, uniqueness: { scope: :provider }

  scope :barong, -> { where(provider: :barong) }

  class << self
    def locate(auth)
      uid      = auth['uid'].to_s
      provider = auth['provider']
      find_by_provider_and_uid(provider, uid)
    end

    def build_auth(auth)
      new \
        uid:      auth['uid'],
        provider: auth['provider'],
        token:    auth.dig('credentials', 'token')
    end
  end
end

# == Schema Information
# Schema version: 20180216145412
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  provider   :string(255)
#  uid        :string(255)
#  token      :text(65535)
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_authentications_on_member_id         (member_id)
#  index_authentications_on_provider_and_uid  (provider,uid)
#
