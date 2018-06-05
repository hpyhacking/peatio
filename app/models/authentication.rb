# encoding: UTF-8
# frozen_string_literal: true

class Authentication < ActiveRecord::Base
  include BelongsToMember

  validates :provider, :uid, presence: true
  validates :member_id, uniqueness: { scope: :provider }
  validates :uid,       uniqueness: { scope: :provider }

  scope :barong, -> { where(provider: :barong) }

  class << self
    def locate(auth)
      find_by_provider_and_uid(auth['provider'], auth['uid'])
    end

    def from_omniauth_data(data)
      new \
        uid:      data['uid'],
        provider: data['provider'],
        token:    data.dig('credentials', 'token')
    end
  end
end

# == Schema Information
# Schema version: 20180605104154
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  provider   :string(30)       not null
#  uid        :string(255)      not null
#  token      :string(1024)
#  member_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_authentications_on_member_id                       (member_id)
#  index_authentications_on_provider_and_member_id          (provider,member_id) UNIQUE
#  index_authentications_on_provider_and_member_id_and_uid  (provider,member_id,uid) UNIQUE
#  index_authentications_on_provider_and_uid                (provider,uid) UNIQUE
#
