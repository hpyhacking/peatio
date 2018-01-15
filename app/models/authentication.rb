class Authentication < ActiveRecord::Base
  belongs_to :member, required: true

  validates :provider, presence: true, uniqueness: { scope: :member_id }
  validates :uid,      presence: true, uniqueness: { scope: :provider }

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
        secret:   auth&.dig('credentials', 'secret'),
        nickname: auth&.dig('info', 'nickname')
    end
  end
end
